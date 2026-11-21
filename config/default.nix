# Core editor settings. Plugins and keymaps live in the sibling modules.
{pkgs, ...}: {
  imports = [
    ./editor.nix
    ./lsp.nix
    ./dotnet.nix
    ./debug.nix
    ./vcs.nix
    ./database.nix
    ./keymaps.nix
  ];

  colorschemes.gruvbox.enable = true;

  globals = {
    mapleader = " ";
    maplocalleader = " ";
    have_nerd_font = true; # alacritty uses BerkeleyMono Nerd Font
  };

  opts = {
    number = true;
    mouse = "a";
    showmode = false; # lualine shows it
    breakindent = true;
    undofile = true;
    ignorecase = true;
    smartcase = true;
    incsearch = true;
    hlsearch = true;
    signcolumn = "yes";
    updatetime = 250;
    timeoutlen = 300; # also how long an overlapping mapping like <leader>w waits
    splitright = true;
    splitbelow = true;
    list = true;
    listchars.__raw = "{ tab = '» ', trail = '·', nbsp = '␣' }";
    inccommand = "split";
    cursorline = true;
    scrolloff = 10;
    termguicolors = true;
    # Treesitter folds where available, but keep files open on load
    # (zac/zao collapse/expand all, zs/zd/zf/zg pick a level).
    foldenable = true;
    foldlevel = 99;
    foldlevelstart = 99;
    foldcolumn = "1";
    # Spell checking: off by default, on for prose filetypes (autoCmd below),
    # <leader>zt toggles it. In code, treesitter limits it to comments and
    # strings; "camel" checks each part of a camelCase word separately.
    spelllang = "en";
    spelloptions = "camel";
  };

  # *.fs is ambiguous (Forth / F#) to Vim's detection.
  filetype.extension = {
    fs = "fsharp";
    fsi = "fsharp";
    fsx = "fsharp";
  };

  diagnostic.settings = {
    virtual_text = true;
    severity_sort = true;
    float.border = "rounded";
  };

  autoGroups.kf-highlight-yank.clear = true;
  autoGroups.kf-spell.clear = true;
  autoGroups.kf-filetype.clear = true;
  autoCmd = [
    {
      # set highlightedyank
      event = ["TextYankPost"];
      desc = "Highlight when yanking (copying) text";
      group = "kf-highlight-yank";
      callback.__raw = "function() vim.hl.on_yank() end";
    }
    {
      event = ["FileType"];
      pattern = ["markdown" "text" "gitcommit" "jjdescription"];
      desc = "Spell check prose";
      group = "kf-spell";
      command = "setlocal spell";
    }
    {
      # Neovim ships no F# ftplugin, so 'commentstring' is empty and gc/gcc
      # (<leader>c) fail with "Option 'commentstring' is empty".
      event = ["FileType"];
      pattern = ["fsharp"];
      desc = "F# line comments";
      group = "kf-filetype";
      callback.__raw = "function() vim.bo.commentstring = '// %s' end";
    }
  ];

  # Lua helpers for keymaps that aren't a single plugin call.
  extraFiles."lua/kf.lua".source = ./lua/kf.lua;

  # F# folds query (nvim-treesitter has none, so .fs buffers had no folds).
  extraFiles."queries/fsharp/folds.scm".source = ./queries/fsharp/folds.scm;

  # Dirs plugins write to without creating them first, which breaks on a fresh
  # account: easy-dotnet's state dir (non-recursive mkdir) and dbee's log
  # (~/.cache/nvim/dbee/dbee.log, else a "Press ENTER" prompt on startup).
  extraConfigLuaPre = ''
    vim.fn.mkdir(vim.fn.stdpath('data'), 'p')
    vim.fn.mkdir(vim.fn.stdpath('cache') .. '/dbee', 'p')
    -- Words added with <leader>za go here, outside the read-only config.
    vim.fn.mkdir(vim.fn.stdpath('data') .. '/spell', 'p')
    vim.opt.spellfile = vim.fn.stdpath('data') .. '/spell/en.utf-8.add'
  '';

  extraConfigLua = ''
    -- clipboard=unnamedplus. WSL needs win32yank; over SSH Neovim falls back
    -- to OSC 52 on its own, so yanks reach the local machine's clipboard.
    if vim.fn.has('wsl') == 1 then
      vim.g.clipboard = {
        name = 'win32yank-wsl',
        copy = { ['+'] = 'win32yank.exe -i', ['*'] = 'win32yank.exe -i' },
        paste = { ['+'] = 'win32yank.exe -o', ['*'] = 'win32yank.exe -o' },
        cache_enabled = 0,
      }
    elseif os.getenv('SSH_TTY') and not os.getenv('WAYLAND_DISPLAY') and not os.getenv('DISPLAY') then
      -- Copy goes to the local clipboard via OSC 52. Alacritty refuses OSC 52
      -- *reads*, so paste from Neovim's own last yank instead of stalling.
      local osc52 = require('vim.ui.clipboard.osc52')
      local function last_yank() return { vim.fn.split(vim.fn.getreg(""), '\n'), vim.fn.getregtype("") } end
      vim.g.clipboard = {
        name = 'osc52-copy',
        copy = { ['+'] = osc52.copy('+'), ['*'] = osc52.copy('*') },
        paste = { ['+'] = last_yank, ['*'] = last_yank },
      }
    end
    vim.opt.clipboard = 'unnamedplus'
  '';

  extraPackages = with pkgs; [
    ripgrep
    fd

    # python
    black
    isort

    # rust
    rust-analyzer
    rustfmt

    # nix
    alejandra

    # terraform
    terraform

    # sql
    sql-formatter

    # markup
    prettier
    jq

    # shell
    shfmt

    # lua
    stylua
  ];
}
