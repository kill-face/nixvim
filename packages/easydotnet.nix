# easy-dotnet-server (`dotnet-easydotnet`): the backend easy-dotnet.nvim talks
# to for the test runner, debugger setup, NuGet, solution management, ...
# https://github.com/GustavEikaas/easy-dotnet-server
#
# The plugin would otherwise `dotnet tool install -g EasyDotnet` itself. It
# targets net8.0 with rollForward=LatestMajor, so it runs on the .NET 10 SDK.
{
  lib,
  buildDotnetGlobalTool,
  dotnetCorePackages,
}:
buildDotnetGlobalTool {
  pname = "easydotnet";
  nugetName = "EasyDotnet";
  version = "3.4.38";
  nugetHash = "sha256-kef7DvRo7RFdgvYpmUeQalGk1PCU81nm6JUzqeos45w=";

  executables = ["dotnet-easydotnet"];

  # Loads projects through MSBuild, so it needs a full SDK at runtime.
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.sdk_10_0;

  meta = {
    description = "Server backing easy-dotnet.nvim (tests, debugging, NuGet, solutions)";
    homepage = "https://github.com/GustavEikaas/easy-dotnet-server";
    license = lib.licenses.mit;
    mainProgram = "dotnet-easydotnet";
  };
}
