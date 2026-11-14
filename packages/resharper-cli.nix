# JetBrains ReSharper Command Line Tools (`jb cleanupcode`, `jb inspectcode`).
#
# This is the only supported way to run the ReSharper engine (what Rider uses
# for inspections/cleanup) outside a JetBrains IDE. Free to use, proprietary.
# https://www.jetbrains.com/help/resharper/ReSharper_Command_Line_Tools.html
{
  lib,
  buildDotnetGlobalTool,
  dotnetCorePackages,
}:
buildDotnetGlobalTool {
  pname = "resharper-cli";
  nugetName = "JetBrains.ReSharper.GlobalTools";
  version = "2026.3.0";
  nugetHash = "sha256-RHCjPaJLfJkduktP+xb892fN8Xc5z/kZLBGaniamL+8=";

  executables = ["jb"];

  # cleanupcode/inspectcode load the solution through MSBuild, so they need a
  # full SDK at runtime, not just the runtime.
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.sdk_10_0;

  meta = {
    description = "ReSharper command line tools: code cleanup and inspections";
    homepage = "https://www.jetbrains.com/help/resharper/ReSharper_Command_Line_Tools.html";
    license = lib.licenses.unfree;
    mainProgram = "jb";
  };
}
