# Core editor settings. Plugins and keymaps live in the sibling modules.
{pkgs, ...}: {
  imports = [
    ./editor.nix
    ./lsp.nix
    ./dotnet.nix
    ./debug.nix
    ./vcs.nix
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
  autoCmd = [
    {
      # set highlightedyank
      event = ["TextYankPost"];
      desc = "Highlight when yanking (copying) text";
      group = "kf-highlight-yank";
      callback.__raw = "function() vim.hl.on_yank() end";
    }
  ];

  # Lua helpers for keymaps that aren't a single plugin call.
  extraFiles."lua/kf.lua".source = ./lua/kf.lua;

  # easy-dotnet creates its state dir non-recursively; make sure the parent
  # exists on a fresh account.
  extraConfigLuaPre = ''
    vim.fn.mkdir(vim.fn.stdpath('data'), 'p')
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

    # markup
    prettier
    jq

    # shell
    shfmt

    # lua
    stylua
  ];
}
