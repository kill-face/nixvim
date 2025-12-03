{
  lsp = {
    enable = true;
    inlayHints = true;

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
      ionide.enable = true;
    };
  };
}
