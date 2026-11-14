# Language servers (Neovim's built-in client, configs from nvim-lspconfig) and
# formatters. C#/F# (SharpLsp) is in dotnet.nix.
{...}: {
  plugins.lspconfig.enable = true;

  lsp = {
    inlayHints.enable = true;

    servers = {
      bashls.enable = true;
      dockerls.enable = true;
      html.enable = true;
      jsonls.enable = true;
      lua_ls.enable = true;
      terraformls.enable = true;
      nixd.enable = true;
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
        fsharp = ["fantomas"];
        json = ["jq"];
        lua = ["stylua"];
        nix = ["alejandra"];
        python = ["isort" "black"];
        rust = ["rustfmt"];
        sh = ["shfmt"];
        terraform = ["terraform_fmt"];
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
