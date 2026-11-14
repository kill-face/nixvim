# Key bindings, kept in the same order and grouping as ~/.ideavimrc so the two
# can be compared side by side. Rider action names are in the descriptions.
# Overlapping keys (<leader>w vs <leader>wb, <leader>as vs <leader>asv) work
# like in IdeaVim: the short one fires after 'timeoutlen' (300ms).
{lib, ...}: let
  lua = code: {__raw = code;};
  fn = code: lua "function() ${code} end";
  map = mode: key: action: desc: {
    inherit mode key action;
    options = {
      inherit desc;
      silent = true;
    };
  };
  # `map` in vimrc = normal, visual and operator-pending; we use normal+visual.
  nv = ["n" "x"];
  kf = name: fn "require('kf').${name}()";
  dotnet = name: fn "require('easy-dotnet').${name}()";
  dap = name: fn "require('dap').${name}()";
  picker = name: fn "Snacks.picker.${name}()";
  move = what: dir: fn "require('nvim-treesitter-textobjects.move').${dir}('${what}', 'textobjects')";
in {
  keymaps = [
    # ---- nvim basics -------------------------------------------------------
    (map "n" "<Esc>" "<cmd>nohlsearch<CR>" "Clear search highlight")
    (map "t" "<Esc><Esc>" "<C-\\><C-n>" "Exit terminal mode")

    # ---- Vim action modifications ------------------------------------------
    (map "v" "d" ''"_d'' "Delete without yanking") # vnoremap d "_d
    (map "x" "p" "P" "Paste without yanking the replaced text") # xnoremap p pgvy
    (map ["n" "x" "o"] "Q" "gq" "Format lines") # map Q gq
    (map "n" "U" "<C-r>" "Redo") # nmap U <C-R>
    (map "v" "<C-r>" ''"hy:%s/<C-r>h//g<left><left>'' "Replace selection in buffer")

    # folds: zac/zao collapse/expand all, zs/zd/zf/zg ExpandToLevel1..4
    (map "n" "zac" "zM" "CollapseAllRegions")
    (map "n" "zao" "zR" "ExpandAllRegions")
    (map "n" "zs" "<cmd>setlocal foldlevel=1<CR>" "ExpandToLevel1")
    (map "n" "zd" "<cmd>setlocal foldlevel=2<CR>" "ExpandToLevel2")
    (map "n" "zf" "<cmd>setlocal foldlevel=3<CR>" "ExpandToLevel3")
    (map "n" "zg" "<cmd>setlocal foldlevel=4<CR>" "ExpandToLevel4")

    # ---- Actions -----------------------------------------------------------
    (map "n" "<leader>as" (kf "stop") "Stop")
    (map "n" "<leader>acds" (kf "db_choose_connection") "Console.Jdbc.ChooseDataSource")
    (map "n" "<leader>acs" (kf "db_choose_database") "Console.Jdbc.ChooseSchema")
    (map "n" "<leader>adr" (kf "db_refresh") "DatabaseView.Refresh")
    (map nv "<leader>es" (kf "db_execute") "Console.Jdbc.Execute")
    (map nv "<leader>am" (fn "vim.lsp.buf.code_action()") "ShowIntentionActions")
    (map nv "<M-CR>" (fn "vim.lsp.buf.code_action()") "ShowIntentionActions (Alt+Enter)")
    (map "n" "<leader>aob" (fn "vim.ui.open(vim.fn.expand('%:p'))") "OpenInBrowser")
    (map "n" "<leader>amvp" "<cmd>MarkdownPreview<CR>" "TextEditorWithPreview.Layout.EditorAndPreview")
    (map "n" "<leader>amve" "<cmd>MarkdownPreviewStop<CR>" "TextEditorWithPreview.Layout.EditorOnly")
    (map "n" "<leader>mp" "<cmd>MarkdownPreviewToggle<CR>" "Toggle Markdown preview")

    (map "n" "<leader>f" (fn "require('conform').format()") "ReformatCode")
    (map "n" "<leader>w" "<cmd>wall<CR>" "SaveAll")
    (map "n" "<leader>q" (fn "Snacks.bufdelete()") "CloseContent")

    # ---- Debugger ----------------------------------------------------------
    (map "n" "<leader>di" (dotnet "debug_default") "Debug")
    (map "n" "<leader>db" (dap "toggle_breakpoint") "ToggleLineBreakpoint")
    (map "n" "<leader>dcb" (kf "conditional_breakpoint") "AddConditionalBreakpoint")
    (map "n" "<leader>dra" (dap "clear_breakpoints") "RemoveAllBreakpoints")
    (map "n" "<leader>drf" (kf "remove_breakpoints_in_file") "RemoveAllBreakpointsInFile")
    (map nv "<leader>de" (fn "require('dapui').eval()") "EvaluateInConsole")
    (map nv "<leader>dw" (kf "add_watch") "AddToWatch")
    (map "n" "<leader>dpp" (fn "require('dapui').float_element('watches', { enter = true })") "WatchesPanelPopup")
    (map "n" "<leader>ds" (dotnet "debug_profile") "Select run configuration (launch profile)")
    (map "n" "<leader>dan" (dotnet "debug_attach") "AttachToProcess")
    (map "n" "<leader>daa" (dap "run_last") "RiderReattach")
    # Rider's default debugger keys
    (map "n" "<F8>" (dap "step_over") "Step over")
    (map "n" "<F7>" (dap "step_into") "Step into")
    (map "n" "<S-F8>" (dap "step_out") "Step out")
    (map "n" "<F9>" (dap "continue") "Resume")
    (map "n" "<S-F9>" (dotnet "debug_default") "Debug")
    (map "n" "<C-F8>" (dap "toggle_breakpoint") "Toggle breakpoint")
    (map "n" "<C-F2>" (kf "stop") "Stop")
    (map nv "<M-F8>" (fn "require('dapui').eval()") "Evaluate")
    (map "n" "<M-F9>" (dap "run_to_cursor") "Run to cursor")

    # ---- Information, Documentation, Usages --------------------------------
    (map "n" "<leader>id" (fn "vim.lsp.buf.hover()") "QuickJavaDoc")
    (map "n" "<leader>ip" (fn "vim.lsp.buf.signature_help()") "ParameterInfo")
    (map "n" "<leader>ii" (picker "lsp_implementations") "QuickImplementations")
    (map "n" "<leader>ifu" (picker "lsp_references") "FindUsages")
    (map "n" "<leader>isu" (picker "lsp_references") "ShowUsages")

    # ---- Testing (easy-dotnet adds buffer-local <leader>xt/xc in test files) -
    (map nv "<leader>xt" (dotnet "testrunner") "RiderUnitTestContextAction (test runner)")
    (map nv "<leader>xa" (dotnet "test_solution") "RunSolution")
    (map nv "<leader>xc" (dotnet "testrunner") "RunContext (test runner)")

    # ---- Comment lines -----------------------------------------------------
    {
      mode = "n";
      key = "<leader>c";
      action = "gcc";
      options = {
        remap = true;
        desc = "CommentByLineComment";
      };
    }
    {
      mode = "x";
      key = "<leader>c";
      action = "gc";
      options = {
        remap = true;
        desc = "CommentByLineComment";
      };
    }

    # ---- Refactoring -------------------------------------------------------
    (map nv "<leader>rr" (fn "require('kf').code_action_kind('refactor')()") "Refactorings.QuickListPopupAction")
    (map "n" "<leader>rn" (fn "vim.lsp.buf.rename()") "RenameElement")
    (map nv "<leader>rm" (fn "require('kf').code_action('^Extract method')()") "ExtractMethod")
    (map nv "<leader>rv" (fn "require('kf').code_action('^Introduce local')()") "IntroduceVariable")
    (map nv "<leader>rf" (fn "require('kf').code_action('^Introduce field')()") "IntroduceField")
    (map nv "<leader>rs" (fn "require('kf').code_action_kind('refactor.rewrite')()") "ChangeSignature / rewrite")
    (map "n" "<leader>rc" (kf "jb_cleanup_file") "ReSharper: Code Cleanup this file")
    (map "n" "<leader>rI" (kf "jb_inspect_solution") "ReSharper: InspectCode solution")

    # ---- Searching, Page Navigation ----------------------------------------
    (map ["n" "x" "o"] "[[" (move "@function.outer" "goto_previous_start") "MethodUp")
    (map ["n" "x" "o"] "]]" (move "@function.outer" "goto_next_start") "MethodDown")
    (map "n" "<leader>gf" (picker "files") "GotoFile")
    (map "n" "<leader>ga" (picker "grep") "SearchEverywhere (text)")
    (map "n" "<leader>gc" (fn "Snacks.picker.lsp_workspace_symbols({ filter = { default = { 'Class', 'Struct', 'Interface', 'Enum' } } })") "GotoClass")
    (map "n" "<leader>gs" (picker "lsp_workspace_symbols") "GotoSymbol")

    # ---- Errors ------------------------------------------------------------
    (map nv "<leader>en" (fn "vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })") "GotoNextError")
    (map nv "<leader>ep" (fn "vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })") "GotoPreviousError")

    # ---- Go to code --------------------------------------------------------
    (map "n" "<leader>gd" (picker "lsp_definitions") "GotoDeclaration")
    (map "n" "<leader>gy" (picker "lsp_type_definitions") "GotoTypeDeclaration")
    (map "n" "<leader>gi" (picker "lsp_implementations") "GotoImplementation")
    (map "n" "<leader>gu" (picker "lsp_references") "ShowUsages")
    (map "n" "<leader>gt" (kf "goto_test") "GotoTest")

    # ---- Jump around (easymotion) ------------------------------------------
    (map ["n" "x" "o"] "<leader>j" (fn "require('flash').jump()") "Jump (easymotion)")

    # ---- Pane navigation (ideavim A-hjkl, old nixvim C-hjkl) ---------------
    (map "n" "<A-h>" "<C-w>h" "Window left")
    (map "n" "<A-l>" "<C-w>l" "Window right")
    (map "n" "<A-k>" "<C-w>k" "Window up")
    (map "n" "<A-j>" "<C-w>j" "Window down")
    (map "n" "<C-h>" "<C-w><C-h>" "Window left")
    (map "n" "<C-l>" "<C-w><C-l>" "Window right")
    (map "n" "<C-j>" "<C-w><C-j>" "Window down")
    (map "n" "<C-k>" "<C-w><C-k>" "Window up")
    # (popup navigation <A-j>/<A-k> in insert mode: editor.nix, blink-cmp)

    # ---- Window focus ------------------------------------------------------
    (map "n" "<leader>wb" (fn "Snacks.explorer()") "NERDTree / project view")
    (map "n" "<leader>wd" (fn "require('dapui').toggle()") "ActivateDebugToolWindow")
    (map "n" "<leader>wp" "<cmd>Trouble diagnostics toggle<CR>" "ActivateProblemsViewToolWindow")
    (map "n" "<leader>wc" "<cmd>Trouble todo toggle<CR>" "ActivateTODOToolWindow")
    (map "n" "<leader>wu" (dotnet "testrunner") "ActivateUnitTestsToolWindow")
    (map "n" "<leader>ws" (fn "require('dbee').toggle()") "ActivateDatabaseToolWindow")
    (map "n" "<leader>wf" (fn "Snacks.explorer.reveal()") "SelectInProjectView")
    (map "n" "<leader>wg" (dotnet "terminal_toggle") "ActivateServicesToolWindow (running apps)")
    (map "n" "<leader>wt" (fn "Snacks.terminal.toggle()") "ActivateTerminalToolWindow")
    (map "n" "<leader>wi" (fn "vim.lsp.buf.hover()") "Documentation")
    (map "n" "<leader>wn" (dotnet "add_package") "ActivateNuGetToolWindow (add package)")
    (map "n" "<leader>wr" (dotnet "run_default") "ActivateRunToolWindow (run)")
    (map "n" "<leader>wo" "<cmd>AerialToggle<CR>" "ActivateStructureToolWindow")
    (map "n" "<leader>we" (dotnet "build_solution_quickfix") "ActivateBuildToolWindow (build)")
    (map "n" "<leader>wm" (picker "resume") "ActivateFindToolWindow (last search)")
    (map "n" "<leader>wvv" (fn "require('jj.cmd').log()") "ActivateVersionControlToolWindow (jj log)")
    (map "n" "<leader>wvc" (fn "require('jj.cmd').commit()") "ActivateCommitToolWindow (jj commit)")
    (map "n" "<leader>wvp" (fn "require('jj.cmd').open_pr()") "ActivatePullRequestsToolWindow (open PR)")

    # ---- Display options ---------------------------------------------------
    (map nv "<leader>ww" (fn "Snacks.zen()") "ToggleDistractionFreeMode")
    (map "n" "<leader>wh" (kf "hide_tool_windows") "HideAllWindows")

    # ---- Tabs --------------------------------------------------------------
    (map "n" "<leader>tp" "<cmd>BufferLineTogglePin<CR>" "PinActiveTab")
    (map "n" "<leader>tu" (kf "reopen_closed") "ReopenClosedTab")
    (map "n" "<C-A-Left>" "<cmd>BufferLineMovePrev<CR>" "Move tab left")
    (map "n" "<C-A-Right>" "<cmd>BufferLineMoveNext<CR>" "Move tab right")

    # ---- Window actions: splits --------------------------------------------
    (map nv "<leader>asv" "<cmd>vsplit<CR>" "SplitVertically")
    (map nv "<leader>ash" "<cmd>split<CR>" "SplitHorizontally")
    (map nv "<leader>asu" "<cmd>only<CR>" "Unsplit")
    (map nv "<leader>asm" "<C-w>x" "MoveEditorToOppositeTabGroup")

    # ---- System clipboard --------------------------------------------------
    (map nv "<leader>y" ''"+y'' "Yank to system clipboard")
    (map nv "<leader>p" ''"+p'' "Paste from system clipboard")
    (map "n" "<leader>R" "<cmd>registers<CR>" "Show registers")

    # ---- REPL (F# Interactive) ---------------------------------------------
    (map nv "<leader>sr" (kf "fsi_send") "SendToFsi")
    (map nv "<leader>ss" (kf "repl_execute") "Console.Execute (SQL: run statement, F#: send to FSI)")
  ];
}
