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
  } @ inputs:
  let
   config = {pkgs, ...}:
     {
	# https://nix-community.github.io/nixvim/NeovimOptions/index.html?highlight=globals#globals
  	globals = {
  	  # Set <space> as the leader key
  	  # See `:help mapleader`
  	  mapleader = " ";
  	  maplocalleader = " ";

  	  # Set to true if you have a Nerd Font installed and selected in the terminal
  	  have_nerd_font = false;
  	};

  	clipboard = {
  	  providers = {
  	    wl-copy.enable = true; # For Wayland
  	    xsel.enable = true; # For X11
  	  };
  	  # Sync clipboard between OS and Neovim
  	  #  Remove this option if you want your OS clipboard to remain independent.
  	  #  See `:help 'clipboard'`
  	  register = "unnamedplus";
  	};

  	# [[ Setting options ]]
  	# See `:help vim.opt`
  	# NOTE: You can change these options as you wish!
  	#  For more options, you can see `:help option-list`
  	# https://nix-community.github.io/nixvim/NeovimOptions/index.html?highlight=globals#opts
  	opts = {
  	  # Show line numbers
  	  number = true;
  	  # You can also add relative line numbers, to help with jumping.
  	  #  Experiment for yourself to see if you like it!
  	  #relativenumber = true

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
  	  # TIP: Disable arrow keys in normal mode
  	  /*
  	  {
  	    mode = "n";
  	    key = "<left>";
  	    action = "<cmd>echo 'Use h to move!!'<CR>";
  	  }
  	  {
  	    mode = "n";
  	    key = "<right>";
  	    action = "<cmd>echo 'Use l to move!!'<CR>";
  	  }
  	  {
  	    mode = "n";
  	    key = "<up>";
  	    action = "<cmd>echo 'Use k to move!!'<CR>";
  	  }
  	  {
  	    mode = "n";
  	    key = "<down>";
  	    action = "<cmd>echo 'Use j to move!!'<CR>";
  	  }
  	  */
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

  	plugins = {
  	  # Detect tabstop and shiftwidth automatically
  	  # https://nix-community.github.io/nixvim/plugins/sleuth/index.html
  	  sleuth = {
  	    enable = true;
  	  };

  	  # "gc" to comment visual regions/lines
  	  # https://nix-community.github.io/nixvim/plugins/comment/index.html
  	  comment = {
  	    enable = true;
  	  };

  	  # Highlight todo, notes, etc in comments
  	  # https://nix-community.github.io/nixvim/plugins/todo-comments/index.html
  	  todo-comments = {
  	    enable = true;
  	    signs = true;
  	  };
  	};
     };
    in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        nixvimLib = nixvim.lib.${system};
        nixvim' = nixvim.legacyPackages.${system};
        nixvimModule = {
          inherit pkgs;
          module = import ./config;
          extraSpecialArgs = {
          };
        };
        nvim = nixvim'.makeNixvimWithModule nixvimModule;
	# _module.args.pkgs = import self.inputs.nixpkgs {
	#   inherit system;
	#   confif.allowUnfree = true;
	# };
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
