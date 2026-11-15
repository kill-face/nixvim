# jj-diffconflicts: a jj merge tool in Neovim (two-way diff of the conflict's
# sides, plus a history tab against the base). Not in nixpkgs.
{
  vimUtils,
  fetchFromGitHub,
}:
vimUtils.buildVimPlugin {
  pname = "jj-diffconflicts";
  version = "0-unstable-2026-05-19";
  src = fetchFromGitHub {
    owner = "rafikdraoui";
    repo = "jj-diffconflicts";
    rev = "a2aa9a247b56d2c1a6f6be81bcf41c5450cc82ff";
    hash = "sha256-MjacjGlBRwActBBGeBZDHz8jz5J3Mt6KoDsf8WKgUDA=";
  };
  meta.homepage = "https://github.com/rafikdraoui/jj-diffconflicts";
}
