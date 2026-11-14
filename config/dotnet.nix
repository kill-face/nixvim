# .NET: SharpLsp (C# + F# language server) and easy-dotnet.nvim (Rider-style
# test runner, run/debug, NuGet, solution management) on Nix-provided tools.
{pkgs, ...}: let
  dotnet-sdk = pkgs.dotnetCorePackages.sdk_10_0;
  sharplsp = pkgs.callPackage ../packages/sharplsp.nix {inherit dotnet-sdk;};
  easydotnet = pkgs.callPackage ../packages/easydotnet.nix {};
  resharper-cli = pkgs.callPackage ../packages/resharper-cli.nix {};
in {
  extraPackages = [
    dotnet-sdk
    easydotnet # dotnet-easydotnet: easy-dotnet's server
    pkgs.netcoredbg
    resharper-cli # jb cleanupcode / inspectcode
    pkgs.csharpier
    pkgs.fantomas
  ];

  # SharpLsp: Roslyn for C#, FSharp.Compiler.Service for F#, one server.
  # If a folder holds several .sln files, pick one in sharplsp.toml:
  #   [csharp]
  #   solution_path = "src/MyApp.sln"
  lsp.servers.sharplsp = {
    enable = true;
    package = sharplsp;
    config = {
      cmd = ["sharplsp" "--stdio"];
      filetypes = ["cs" "fsharp"];
      root_dir.__raw = "function(bufnr, on_dir) require('kf').dotnet_root(bufnr, on_dir) end";
    };
  };

  plugins.easy-dotnet = {
    enable = true;
    settings = {
      picker = "snacks";

      # SharpLsp is the language server; easy-dotnet's Roslyn client stays off.
      lsp.enabled = false;

      debugger = {
        # The netcoredbg easy-dotnet bundles is not patched for NixOS.
        bin_path = "${pkgs.netcoredbg}/bin/netcoredbg";
        auto_register_dap = true;
        console = "integratedTerminal";
      };

      # Rider-style test runner. Keys follow ~/.ideavimrc (<leader>x… tests,
      # <leader>d… debug) instead of easy-dotnet's <leader>r/<leader>d/<leader>t,
      # which would shadow the refactor/debug/tab prefixes.
      test_runner = {
        viewmode = "split";
        mappings = {
          run_test_from_buffer = {
            lhs = "<leader>xt";
            desc = "run test under cursor";
          };
          run_all_tests_from_buffer = {
            lhs = "<leader>xc";
            desc = "run all tests in file";
          };
          debug_test_from_buffer = {
            lhs = "<leader>dt";
            desc = "debug test under cursor";
          };
          peek_stack_trace_from_buffer = {
            lhs = "<leader>xp";
            desc = "peek test output / stack trace";
          };
          # inside the test runner window
          run = {
            lhs = "<leader>xt";
            desc = "run test";
          };
          run_all = {
            lhs = "<leader>xa";
            desc = "run all tests";
          };
          debug_test = {
            lhs = "<leader>dt";
            desc = "debug test";
          };
          peek_stacktrace = {
            lhs = "<leader>xp";
            desc = "peek stack trace";
          };
          go_to_file = {
            lhs = "<leader>gd";
            desc = "go to test";
          };
          get_build_errors = {
            lhs = "<leader>en";
            desc = "show build errors";
          };
        };
      };

      auto_bootstrap_namespace = {
        type = "file_scoped";
        enabled = true;
      };
    };
  };
}
