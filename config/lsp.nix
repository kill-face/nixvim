# Language servers (Neovim's built-in client, configs from nvim-lspconfig) and
# formatters. C#/F# (SharpLsp) is in dotnet.nix.
{...}: {
  plugins.lspconfig.enable = true;

  lsp = {
    # Off by default (SharpLsp's F# type hints are noisy); <leader>ih toggles.
    inlayHints.enable = false;

    servers = {
      bashls.enable = true;
      dockerls.enable = true;
      html.enable = true;
      jsonls.enable = true;
      lua_ls.enable = true;
      terraformls.enable = true;
      # nixd asks for its settings on startup and logs an error on every
      # file when it gets none, so give it some.
      nixd = {
        enable = true;
        config.settings.nixd = {
          nixpkgs.expr = "import <nixpkgs> { }";
          formatting.command = ["alejandra"];
        };
      };
      yamlls.enable = true;
      pylsp.enable = true;
      ruff.enable = true;
    };
  };

  # <leader>f (ReformatCode). Filetypes are Neovim's: C# is "cs", not "csharp".
  plugins.conform-nvim = {
    enable = true;
    settings = {
      default_format_opts.lsp_format = "fallback";
      formatters_by_ft = {
        "_" = ["trim_whitespace"];
        # CSharpier when the repo uses it, else `dotnet format whitespace`
        cs.__raw = "function(bufnr) return require('kf').csharp_formatters(bufnr) end";
        # The injected formatter reads ranges from the current buffer. Run it
        # before Fantomas can move those ranges. Conform shares one timeout
        # across both steps, and a larger F# file can exceed its 1s default.
        fsharp.__raw = "{ 'injected', 'fantomas', timeout_ms = 5000 }";
        json = ["jq"];
        lua = ["stylua"];
        nix = ["alejandra"];
        python = ["isort" "black"];
        rust = ["rustfmt"];
        sh = ["shfmt"];
        # sqp-fmt where it's installed (only changes whitespace and keyword
        # case; reads sqp-fmt.toml), else sql-formatter.
        sql.__raw = "{ 'sqp_fmt', 'sql_formatter', stop_after_first = true }";
        terraform = ["terraform_fmt"];
      };
      # Not packaged here: on PATH only where it's installed (~/code/personal/sqp-fmt).
      # --stdin-filepath lets it find the file's sqp-fmt.toml.
      formatters.sqp_fmt = {
        command = "sqp-fmt";
        args = ["--stdin-filepath" "$FILENAME"];
        stdin = true;
      };
      # T-SQL, uppercase keywords, 4-space indent, unless the repo has its own
      # .sql-formatter.json above the file. (The CLI only looks for one above
      # Neovim's cwd, and -c skips the lookup, so find it here.)
      formatters.sql_formatter = {
        # The CLI can return empty output on Conform's stdin pipe. Give it
        # Conform's temporary file, including when formatting an injection.
        stdin = false;
        args = ["--fix" "$FILENAME"];
        prepend_args.__raw = ''
          function(_, ctx)
            local repo = vim.fs.find('.sql-formatter.json', { upward = true, path = ctx.dirname })[1]
            return { '-c', repo or '{"language":"tsql","keywordCase":"upper","tabWidth":4}' }
          end
        '';
      };
      formatters.dotnet_format_whitespace = {
        # Roslyn's formatter with the repo's .editorconfig. conform writes the
        # buffer to a temp file next to the original, so .editorconfig applies.
        command = "dotnet";
        args = ["format" "whitespace" "$DIRNAME" "--folder" "--include" "$FILENAME"];
        stdin = false;
        cwd.__raw = "require('conform.util').root_file({ '.editorconfig', '.git', '.jj' })";
      };
    };
  };
}
