{
  lsp = {
    enable = true;
    inlayHints = true;

    # https://github.com/nix-community/nixvim/blob/main/plugins/lsp/lsp-packages.nix
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
      omnisharp.enable = true;
      fsharp_language_server.enable = true;
    };
  };
}
