# Editor UI: picker/explorer/terminal (snacks), completion, treesitter,
# statusline, tabs, problems panel, outline, motion and surround plugins.
{...}: {
  plugins = {
    web-devicons.enable = true;

    # Picker (Search Everywhere / Go to *), explorer (NERDTree / project view),
    # terminal, zoom (distraction free), buffer delete, notifications, input.
    snacks = {
      enable = true;
      settings = {
        picker.enabled = true;
        explorer.enabled = true;
        terminal.enabled = true;
        zen.enabled = true;
        bufdelete.enabled = true;
        notifier.enabled = true;
        input.enabled = true;
        indent.enabled = true;
        words.enabled = true; # highlight other references of the symbol under the cursor
        bigfile.enabled = true;
      };
    };

    which-key = {
      enable = true;
      settings = {
        delay = 300;
        spec = [
          {
            __unkeyed-1 = "<leader>a";
            group = "actions";
          }
          {
            __unkeyed-1 = "<leader>as";
            group = "splits / stop";
          }
          {
            __unkeyed-1 = "<leader>ac";
            group = "database console";
          }
          {
            __unkeyed-1 = "<leader>ad";
            group = "database view";
          }
          {
            __unkeyed-1 = "<leader>d";
            group = "debug";
          }
          {
            __unkeyed-1 = "<leader>dr";
            group = "remove breakpoints";
          }
          {
            __unkeyed-1 = "<leader>da";
            group = "attach";
          }
          {
            __unkeyed-1 = "<leader>e";
            group = "errors";
          }
          {
            __unkeyed-1 = "<leader>g";
            group = "go to";
          }
          {
            __unkeyed-1 = "<leader>i";
            group = "info";
          }
          {
            __unkeyed-1 = "<leader>r";
            group = "refactor";
          }
          {
            __unkeyed-1 = "<leader>s";
            group = "repl";
          }
          {
            __unkeyed-1 = "<leader>t";
            group = "tabs";
          }
          {
            __unkeyed-1 = "<leader>w";
            group = "windows / save all";
          }
          {
            __unkeyed-1 = "<leader>wv";
            group = "version control";
          }
          {
            __unkeyed-1 = "<leader>x";
            group = "tests";
          }
        ];
      };
    };

    # Completion. <A-j>/<A-k> move in the popup (ideavim imap A-j/A-k).
    blink-cmp = {
      enable = true;
      settings = {
        keymap = {
          preset = "default";
          "<A-j>" = ["select_next" "fallback"];
          "<A-k>" = ["select_prev" "fallback"];
          "<CR>" = ["accept" "fallback"];
        };
        completion = {
          documentation.auto_show = true;
          list.selection.preselect = false;
        };
        signature.enabled = true;
        sources.default = ["lsp" "path" "snippets" "buffer"];
      };
    };

    treesitter = {
      enable = true;
      highlight.enable = true;
      folding.enable = true;
      # grammarPackages defaults to all grammars
    };
    treesitter-textobjects.enable = true; # [[ / ]] method navigation (keymaps.nix)

    lualine = {
      enable = true;
      settings.options.globalstatus = true;
    };

    # Tabs, with pinning (ideavim <leader>tp) and moving (C-A-Left/Right).
    bufferline = {
      enable = true;
      settings.options = {
        diagnostics = "nvim_lsp";
        offsets = [
          {
            filetype = "snacks_layout_box";
            text = "Explorer";
          }
        ];
      };
    };

    # Problems / TODO / build errors / usages panels.
    trouble.enable = true;

    # Structure tool window.
    aerial = {
      enable = true;
      settings = {
        backends = ["lsp" "treesitter"];
        layout.default_direction = "right";
      };
    };

    todo-comments = {
      enable = true;
      settings.signs = true;
    };

    flash.enable = true; # set easymotion  (<leader>j)
    nvim-surround.enable = true; # set surround (ys / cs / ds, like vim-surround)
    sleuth.enable = true; # detect indentation
    fidget.enable = true; # LSP progress (SharpLsp loading the solution)
    nvim-autopairs.enable = true;
    conjure.enable = true; # scheme / lisp REPL

    # Markdown preview in the browser (<leader>mp, <leader>amvp / <leader>amve)
    markdown-preview = {
      enable = true;
      settings = {
        auto_start = 0;
        auto_close = 1;
        echo_preview_url = 1;
        filetypes = ["markdown"];
        preview_options = {
          hide_yaml_meta = 1;
          sync_scroll_type = "middle";
        };
      };
    };
  };
}
