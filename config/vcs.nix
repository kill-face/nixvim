# Version control: jj.nvim (log/status/describe/new/squash/rebase/bookmarks/
# push from Neovim) and gitsigns for gutter change marks (works in colocated
# jj repos, where .git exists).
{...}: {
  plugins = {
    jj = {
      enable = true;
      settings.picker.snacks = {};
    };
    gitsigns.enable = true;
  };
}
