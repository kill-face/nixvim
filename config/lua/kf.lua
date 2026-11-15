-- Glue for the Rider/IdeaVim-style mappings that aren't a single plugin call.
local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "nixvim" })
end

-------------------------------------------------------------------------------
-- Projects / solutions
-------------------------------------------------------------------------------

local function find_up(patterns, start)
  local found = vim.fs.find(function(name)
    for _, p in ipairs(patterns) do
      if name:match(p) then return true end
    end
    return false
  end, { upward = true, path = start or vim.fn.expand("%:p:h"), limit = 1 })
  return found[1]
end

function M.solution_file(start) return find_up({ "%.sln$", "%.slnx$" }, start) end
function M.project_file(start) return find_up({ "%.csproj$", "%.fsproj$", "%.vbproj$" }, start) end

--- Root for SharpLsp: the solution dir, else the project dir, else the git/jj root.
function M.dotnet_root(bufnr, on_dir)
  local start = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  local file = M.solution_file(start) or M.project_file(start)
  local root = file and vim.fs.dirname(file) or vim.fs.root(bufnr, { ".jj", ".git" })
  if root then on_dir(root) end
end

-------------------------------------------------------------------------------
-- Formatting: CSharpier if the repo opts in, else `dotnet format whitespace`
-- (Roslyn + .editorconfig, the closest to Rider's Reformat Code).
-------------------------------------------------------------------------------

function M.csharp_formatters(bufnr)
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  local cfg = vim.fs.find({ ".csharpierrc", ".csharpierrc.json", ".csharpierrc.yaml", ".csharpierrc.yml", ".csharpierignore" },
    { upward = true, path = dir, limit = 1 })[1]
  if cfg then return { "csharpier" } end
  local tools = vim.fs.find(".config/dotnet-tools.json", { upward = true, path = dir, limit = 1 })[1]
  if tools then
    local f = io.open(tools)
    if f then
      local text = f:read("*a")
      f:close()
      if text:find("csharpier", 1, true) then return { "csharpier" } end
    end
  end
  return { "dotnet_format_whitespace" }
end

-------------------------------------------------------------------------------
-- LSP code actions by title (Extract method, Introduce local, ...)
-------------------------------------------------------------------------------

function M.code_action(pattern)
  return function()
    vim.lsp.buf.code_action({
      filter = function(action) return action.title:match(pattern) ~= nil end,
      apply = true,
    })
  end
end

function M.code_action_kind(kind)
  return function() vim.lsp.buf.code_action({ context = { only = { kind }, diagnostics = {} } }) end
end

-------------------------------------------------------------------------------
-- Navigation
-------------------------------------------------------------------------------

--- GotoTest: Foo.cs <-> FooTests.cs / FooTest.cs
function M.goto_test()
  local file = vim.api.nvim_buf_get_name(0)
  local ext = vim.fn.fnamemodify(file, ":e")
  local base = vim.fn.fnamemodify(file, ":t:r")
  local subject = base:match("^(.-)Tests?$")
  local wanted = subject and { subject .. "." .. ext } or { base .. "Tests." .. ext, base .. "Test." .. ext }
  local root = vim.fs.root(0, { ".jj", ".git", "*.sln", "*.slnx" }) or vim.fn.getcwd()
  local hits = vim.fs.find(wanted, { path = root, type = "file", limit = 10 })
  if #hits == 0 then
    notify("No " .. table.concat(wanted, " / ") .. " under " .. root, vim.log.levels.WARN)
  elseif #hits == 1 then
    vim.cmd.edit(vim.fn.fnameescape(hits[1]))
  else
    vim.ui.select(hits, { prompt = "Go to" }, function(choice)
      if choice then vim.cmd.edit(vim.fn.fnameescape(choice)) end
    end)
  end
end

--- ReopenClosedTab
local closed = {}
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(args)
    local name = vim.api.nvim_buf_get_name(args.buf)
    if name ~= "" and vim.bo[args.buf].buftype == "" then table.insert(closed, name) end
  end,
})
function M.reopen_closed()
  while #closed > 0 do
    local file = table.remove(closed)
    if vim.uv.fs_stat(file) then return vim.cmd.edit(vim.fn.fnameescape(file)) end
  end
  notify("No closed file to reopen", vim.log.levels.WARN)
end

--- HideAllWindows: close tool windows (tree, debugger, trouble, terminals,
--- outline, quickfix), keep the editors.
function M.hide_tool_windows()
  pcall(function() require("dapui").close() end)
  pcall(function() require("trouble").close() end)
  pcall(function() require("aerial").close_all() end)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local bt, ft = vim.bo[buf].buftype, vim.bo[buf].filetype
    local is_tool = bt == "terminal" or bt == "quickfix" or bt == "nofile" or ft:match("^snacks_") or ft:match("^dap")
    if is_tool and #vim.api.nvim_tabpage_list_wins(0) > 1 then pcall(vim.api.nvim_win_close, win, false) end
  end
end

-------------------------------------------------------------------------------
-- Debugger
-------------------------------------------------------------------------------

function M.conditional_breakpoint()
  vim.ui.input({ prompt = "Condition: " }, function(cond)
    if cond and cond ~= "" then require("dap").set_breakpoint(cond) end
  end)
end

function M.remove_breakpoints_in_file()
  local bps = require("dap.breakpoints")
  local buf = vim.api.nvim_get_current_buf()
  bps.clear(buf)
  -- tell a running session, if any
  local session = require("dap").session()
  if session then session:set_breakpoints(bps.get(buf)) end
end

function M.add_watch()
  local expr = vim.fn.mode():match("[vV]") and table.concat(vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos(".")), "\n")
    or vim.fn.expand("<cexpr>")
  require("dapui").elements.watches.add(expr)
end

--- Rider's Stop: end the debug session and any running `dotnet run`.
function M.stop()
  local dap = require("dap")
  if dap.session() then dap.terminate() end
  pcall(function() require("easy-dotnet").stop() end)
end

-------------------------------------------------------------------------------
-- VCS
-------------------------------------------------------------------------------

--- Open the diff of the working copy (jj's @) against its parent, or close it.
function M.diffview_toggle()
  if require("diffview.lib").get_current_view() then
    vim.cmd("DiffviewClose")
  else
    vim.cmd("DiffviewOpen")
  end
end

-------------------------------------------------------------------------------
-- F# Interactive (Rider's Send to F# Interactive)
-------------------------------------------------------------------------------

local fsi
local function fsi_terminal()
  if fsi and fsi:buf_valid() then
    if not fsi:win_valid() then fsi:show() end
    return fsi
  end
  fsi = Snacks.terminal.open({ "dotnet", "fsi" }, { win = { position = "bottom", height = 0.3 }, interactive = false })
  return fsi
end

function M.fsi_send()
  local lines
  if vim.fn.mode():match("[vV]") then
    lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
  else
    lines = { vim.api.nvim_get_current_line() }
  end
  local term = fsi_terminal()
  local chan = vim.bo[term.buf].channel
  vim.api.nvim_chan_send(chan, table.concat(lines, "\n") .. "\n;;\n")
end

-------------------------------------------------------------------------------
-- Database console (DataGrip / Rider database tools) on nvim-dbee
-------------------------------------------------------------------------------

local function dbee_api() return require("dbee.api") end

--- dbee's default layout, except that closing it on quit is deferred a tick.
--- Upstream closes all dbee windows from QuitPre, which swallows `:qa` (you'd
--- have to quit twice). Deferred, `:qa` exits right away and `:q` in a dbee
--- window still closes the whole dbee layout.
function M.dbee_layout()
  local layout = require("dbee.layouts").Default:new()
  function layout:configure_window_on_quit(winid)
    vim.api.nvim_create_autocmd("QuitPre", {
      callback = function()
        if vim.api.nvim_get_current_win() ~= winid then return end
        vim.schedule(function()
          if self:is_open() then self:close() end
        end)
      end,
    })
  end
  return layout
end

--- The selection, or the statement under the cursor: the block of lines
--- between blank lines / `GO` separators (like DataGrip's Ctrl+Enter).
local function query_at_cursor()
  if vim.fn.mode():match("[vV\22]") then
    local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
    return table.concat(lines, "\n")
  end
  local function is_break(l)
    local line = vim.fn.getline(l)
    return line:match("^%s*$") or line:match("^%s*[Gg][Oo]%s*$")
  end
  local cur, last = vim.fn.line("."), vim.fn.line("$")
  local s, e = cur, cur
  while s > 1 and not is_break(s - 1) do s = s - 1 end
  while e < last and not is_break(e + 1) do e = e + 1 end
  return table.concat(vim.api.nvim_buf_get_lines(0, s - 1, e, false), "\n")
end

--- Console.Execute: run the selection / statement on the current connection.
function M.db_execute()
  local query = query_at_cursor()
  if query:match("^%s*$") then return notify("Nothing to run here", vim.log.levels.WARN) end
  if not dbee_api().core.get_current_connection() then
    return M.db_choose_connection(function() require("dbee").execute(query) end)
  end
  require("dbee").execute(query)
end

--- ChooseDataSource: pick the active connection from every source.
function M.db_choose_connection(after)
  local core = dbee_api().core
  local items = {}
  for _, source in ipairs(core.get_sources()) do
    for _, conn in ipairs(core.source_get_connections(source:name())) do
      items[#items + 1] = conn
    end
  end
  if #items == 0 then
    return notify("No connections. Add one in the dbee drawer (<leader>ws) or ~/.local/state/nvim/dbee/persistence.json",
      vim.log.levels.WARN)
  end
  vim.ui.select(items, {
    prompt = "Data source",
    format_item = function(c) return string.format("%s  (%s)", c.name, c.type) end,
  }, function(conn)
    if not conn then return end
    core.set_current_connection(conn.id)
    notify("Data source: " .. conn.name)
    if type(after) == "function" then after() end
  end)
end

--- ChooseSchema: switch database on the current connection.
function M.db_choose_database()
  local core = dbee_api().core
  local conn = core.get_current_connection()
  if not conn then return M.db_choose_connection(M.db_choose_database) end
  local ok, current, available = pcall(core.connection_list_databases, conn.id)
  if not ok or not available or #available == 0 then
    return notify("This connection can't switch databases", vim.log.levels.WARN)
  end
  vim.ui.select(available, { prompt = "Database (current: " .. tostring(current) .. ")" }, function(db)
    if not db then return end
    core.connection_select_database(conn.id, db)
    notify("Database: " .. db)
  end)
end

--- DatabaseView.Refresh
function M.db_refresh()
  require("dbee").open()
  dbee_api().ui.drawer_refresh()
end

--- Console.Execute on <leader>ss: SQL goes to the database, anything else to FSI.
function M.repl_execute()
  if vim.bo.filetype == "sql" or vim.bo.filetype == "mysql" or vim.bo.filetype == "plsql" then
    return M.db_execute()
  end
  M.fsi_send()
end

-------------------------------------------------------------------------------
-- ReSharper command line tools: the supported way to run Rider's engine
-- outside a JetBrains IDE. Both load the whole solution (15s+).
-------------------------------------------------------------------------------

local function jb_target()
  local target = M.solution_file() or M.project_file()
  if not target then notify("No .sln/.slnx or project above this file", vim.log.levels.ERROR) end
  return target
end

function M.jb_cleanup_file()
  local file = vim.api.nvim_buf_get_name(0)
  local target = jb_target()
  if not target then return end
  vim.cmd.write()
  local dir = vim.fs.dirname(target)
  local rel = vim.fs.relpath(dir, file) or file
  notify("ReSharper cleanup: " .. rel .. " ...")
  vim.system({ "jb", "cleanupcode", target, "--include=" .. rel }, { cwd = dir, text = true }, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        notify("jb cleanupcode failed:\n" .. (res.stderr ~= "" and res.stderr or res.stdout), vim.log.levels.ERROR)
      else
        vim.cmd.checktime()
        notify("ReSharper cleanup done: " .. rel)
      end
    end)
  end)
end

function M.jb_inspect_solution()
  local target = jb_target()
  if not target then return end
  local dir = vim.fs.dirname(target)
  local out = vim.fn.tempname() .. ".sarif"
  notify("ReSharper InspectCode on " .. vim.fs.basename(target) .. " ...")
  vim.system({ "jb", "inspectcode", target, "--format=Sarif", "--output=" .. out }, { cwd = dir, text = true }, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        return notify("jb inspectcode failed:\n" .. (res.stderr ~= "" and res.stderr or res.stdout), vim.log.levels.ERROR)
      end
      local f = io.open(out)
      if not f then return notify("No SARIF report written", vim.log.levels.ERROR) end
      local sarif = vim.json.decode(f:read("*a"))
      f:close()
      local items = {}
      for _, r in ipairs((sarif.runs[1] or {}).results or {}) do
        local loc = (r.locations or {})[1] or {}
        local phys = loc.physicalLocation or {}
        local uri = (phys.artifactLocation or {}).uri or ""
        local path
        if uri:match("^file://") then
          path = vim.uri_to_fname(uri)
        else -- relative to the solution, percent-encoded
          path = vim.fs.joinpath(dir, (uri:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)))
        end
        local region = phys.region or {}
        table.insert(items, {
          filename = path,
          lnum = region.startLine or 1,
          col = region.startColumn or 1,
          type = ({ error = "E", note = "I" })[r.level] or "W",
          text = string.format("%s [%s]", (r.message or {}).text or "", r.ruleId or "?"),
        })
      end
      vim.fn.setqflist({}, " ", { title = "ReSharper inspections", items = items })
      notify(string.format("ReSharper: %d issue(s)", #items))
      require("trouble").open("qflist")
    end)
  end)
end

return M
