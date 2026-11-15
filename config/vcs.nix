# Version control: jj.nvim (log/status/describe/new/squash/rebase/bookmarks/
# push from Neovim), gitsigns for gutter change marks and diffview for
# side-by-side diffs and file history (both read git, which works in
# colocated jj repos: git's HEAD is jj's @-, so the working tree is @).
# Conflicts: jj-diffconflicts, which `jj resolve` runs as its merge tool
# (configured in ~/nix/nixos home/apps/jj).
{pkgs, ...}: {
  plugins = {
    jj = {
      enable = true;
      settings.picker.snacks = {};
    };
    gitsigns.enable = true;
    diffview = {
      enable = true;
      settings.enhanced_diff_hl = true;
    };
  };

  extraPlugins = [(pkgs.callPackage ../packages/jj-diffconflicts.nix {})];

  # Neovim 0.12's defaults plus: align moved/changed blocks better, highlight
  # the changed words inside a line (like Rider) and a histogram diff.
  opts.diffopt = "internal,filler,closeoff,indent-heuristic,algorithm:histogram,linematch:60,inline:word";
}
