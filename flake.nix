{
  description = "Nixvim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {
    nixvim,
    flake-parts,
    ...
  } @ inputs: let
    config = {pkgs, ...}: {
      colorschemes.gruvbox.enable = true;

      # https://nix-community.github.io/nixvim/NeovimOptions/index.html?highlight=globals#globals
      globals = {
        # Set <space> as the leader key
        # See `:help mapleader`
        mapleader = " ";
        maplocalleader = " ";

        # Set to true if you have a Nerd Font installed and selected in the terminal
        have_nerd_font = false;
      };

      # clipboard = {
      #   # providers = {
      #   #   wl-copy.enable = true; # For Wayland
      #   #   xsel.enable = true; # For X11
      #   #};
      #   # Sync clipboard between OS and Neovim
      #   #  Remove this option if you want your OS clipboard to remain independent.
      #   #  See `:help 'clipboard'`
      #   register = "unnamedplus";
      # };

      # [[ Setting options ]]
      # See `:help vim.opt`
      # NOTE: You can change these options as you wish!
      #  For more options, you can see `:help option-list`
      # https://nix-community.github.io/nixvim/NeovimOptions/index.html?highlight=globals#opts
      opts = {
        # Show line numbers
        number = true;

        # Enable mouse mode, can be useful for resizing splits for example!
        mouse = "a";

        # Don't show the mode, since it's already in the statusline
        showmode = false;

        # Enable break indent
        breakindent = true;

        # Save undo history
        undofile = true;

        # Case-insensitive searching UNLESS \C or one or more capital letters in search term
        ignorecase = true;
        smartcase = true;

        # Keep signcolumn on by default
        signcolumn = "yes";

        # Decrease update time
        updatetime = 250;

        # Decrease mapped sequence wait time
        # Displays which-key popup sooner
        timeoutlen = 300;

        # Configure how new splits should be opened
        splitright = true;
        splitbelow = true;

        # Sets how neovim will display certain whitespace characters in the editor
        #  See `:help 'list'`
        #  See `:help 'listchars'`
        list = true;
        # NOTE: .__raw here means that this field is raw lua code
        listchars.__raw = "{ tab = '» ', trail = '·', nbsp = '␣' }";

        # Preview subsitutions live, as you type!
        inccommand = "split";

        # Show which line your cursor is on
        cursorline = true;

        # Minimal number of screen lines to keep above and below the cursor
        scrolloff = 10;

        # Set highlight on search, but clear on pressing <Esc> in normal mode
        hlsearch = true;
      };

      # [[ Basic Keymaps ]]
      #  See `:help vim.keymap.set()`
      # https://nix-community.github.io/nixvim/keymaps/index.html
      keymaps = [
        {
          mode = "n";
          key = "<Esc>";
          action = "<cmd>nohlsearch<CR>";
        }
        # Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
        # for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
        # is not what someone will guess without a bit more experience.
        #
        # NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
        # or just use <C-\><C-n> to exit terminal mode
        {
          mode = "t";
          key = "<Esc><Esc>";
          action = "<C-\\><C-n>";
          options = {
            desc = "Exit terminal mode";
          };
        }
        {
          mode = "n";
          key = "<leader>f";
          action = "<cmd>lua require('conform').format()<CR>";
          options = {
            desc = "Format document";
          };
        }
        {
          mode = "v";
          key = "x";
          action = "d";
          options = {
            desc = "Delete selected text";
          };
        }
        {
          mode = "n";
          key = "U";
          action = "<C-R>";
          options = {
            desc = "Redo with 'U' makes more sense given that 'u' is undo";
          };
        }
        # Keybinds to make split navigation easier.
        #  Use CTRL+<hjkl> to switch between windows
        #
        #  See `:help wincmd` for a list of all window commands
        {
          mode = "n";
          key = "<C-h>";
          action = "<C-w><C-h>";
          options = {
            desc = "Move focus to the left window";
          };
        }
        {
          mode = "n";
          key = "<C-l>";
          action = "<C-w><C-l>";
          options = {
            desc = "Move focus to the right window";
          };
        }
        {
          mode = "n";
          key = "<C-j>";
          action = "<C-w><C-j>";
          options = {
            desc = "Move focus to the lower window";
          };
        }
        {
          mode = "n";
          key = "<C-k>";
          action = "<C-w><C-k>";
          options = {
            desc = "Move focus to the upper window";
          };
        }
      ];

      # https://nix-community.github.io/nixvim/NeovimOptions/autoGroups/index.html
      autoGroups = {
        kickstart-highlight-yank = {
          clear = true;
        };
      };

      # [[ Basic Autocommands ]]
      #  See `:help lua-guide-autocommands`
      # https://nix-community.github.io/nixvim/NeovimOptions/autoCmd/index.html
      autoCmd = [
        # Highlight when yanking (copying) text
        #  Try it with `yap` in normal mode
        #  See `:help vim.highlight.on_yank()`
        {
          event = ["TextYankPost"];
          desc = "Highlight when yanking (copying) text";
          group = "kickstart-highlight-yank";
          callback.__raw = ''
            function()
              vim.highlight.on_yank()
            end
          '';
        }
      ];

      extraPackages = with pkgs; [
        #python
        black
        isort

        # csharp
        dotnet-sdk

        #rust
        rust-analyzer
        rustfmt

        # nix
        alejandra
        #nixpkgs-fmt

        # terraform
        terraform

        # markup languages
        nodePackages.prettier
        jq

        # shell
        shfmt

        # lua
        stylua

        # scheme
        conjure
      ];

      plugins =
        {
          # Highlight todo, notes, etc in comments
          # https://nix-community.github.io/nixvim/plugins/todo-comments/index.html
          todo-comments = {
            enable = true;
            settings.signs = true;
          };

          # Detect tabstop and shiftwidth automatically
          sleuth.enable = true;
          # "gc" to comment visual regions/lines
          comment.enable = true;
          conform-nvim = {
            enable = true;

            settings = {
              formatters_by_ft = {
                "_" = ["trim_whitespace"];
                csharp = ["csharpier"];
                json = ["jq"];
                lua = ["stylua"];
                nix = ["alejandra"];
                python = ["isort" "black"];
                rust = ["rustfmt"];
                sh = ["shfmt"];
                terraform = ["terraform_fmt"];
              };
            };
          };
          conjure.enable = true;
          cmp-path.enable = true;
          luasnip.enable = true;
          cmp.enable = true;
          web-devicons.enable = true;
          #leap.enable = true;
          telescope = {
            enable = true;
            #fzf-native.enable = true;
          };
        }
        // (import ./plugins/lsp);

      extraConfigLua = ''
        -- Detect WSL at runtime within Neovim
        if vim.fn.has('wsl') == 1 then
          -- We are in WSL: Explicitly configure win32yank.exe
          vim.g.clipboard = {
            name = 'win32yank-wsl',
            copy = {
              ['+'] = 'win32yank.exe -i',
              ['*'] = 'win32yank.exe -i',
            },
            paste = {
              ['+'] = 'win32yank.exe -o',
              ['*'] = 'win32yank.exe -o',
            },
            cache_enabled = 0, -- Disable caching for direct interaction
          }
          -- Still set clipboard=unnamedplus to integrate with the '+' register by default
          vim.opt.clipboard = 'unnamedplus'
          print("NixVim: Configured clipboard for WSL (win32yank.exe)") -- Optional debug
        else
          -- We are NOT in WSL (Native Linux): Rely on auto-detection or configure Linux tools
          -- This assumes wl-clipboard/xsel are installed (conditionally or always)
          vim.opt.clipboard = 'unnamedplus'
          print("NixVim: Configured clipboard for Linux (auto-detect)") -- Optional debug
          -- If auto-detection fails on Linux, you could explicitly configure wl-copy/xsel here:
          -- vim.g.clipboard = { name = 'wl-clipboard', copy = {...}, paste = {...} }
        end
      '';
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = {system, ...}: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
        nixvimLib = nixvim.lib.${system};
        nixvim' = nixvim.legacyPackages.${system};
        nixvimModule = {
          inherit pkgs;
          module = config;
          extraSpecialArgs = {
          };
        };
        nvim = nixvim'.makeNixvimWithModule nixvimModule;
      in {
        checks = {
          default = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;
        };

        formatter = pkgs.alejandra;

        packages = {
          default = nvim;
        };
      };
    };
}
