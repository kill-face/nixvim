{
  description = "Nixvim: Neovim set up as a Rider-style .NET IDE with IdeaVim-aligned keys";

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
    flake-parts.lib.mkFlake {inherit inputs;} {
      # SharpLsp is packaged from its linux-x64 release archive.
      systems = ["x86_64-linux"];

      perSystem = {system, ...}: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true; # ReSharper command line tools
        };
        nixvimModule = {
          inherit pkgs;
          module = ./config;
        };
        nvim = nixvim.legacyPackages.${system}.makeNixvimWithModule nixvimModule;
      in {
        checks.default = nixvim.lib.${system}.check.mkTestDerivationFromNixvimModule nixvimModule;

        formatter = pkgs.alejandra;

        packages = {
          default = nvim;
          sharplsp = pkgs.callPackage ./packages/sharplsp.nix {dotnet-sdk = pkgs.dotnetCorePackages.sdk_10_0;};
          easydotnet = pkgs.callPackage ./packages/easydotnet.nix {};
          resharper-cli = pkgs.callPackage ./packages/resharper-cli.nix {};
        };
      };
    };
}
