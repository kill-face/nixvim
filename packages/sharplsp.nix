# SharpLsp: open-source C# + F# language server (Roslyn + FSharp.Compiler.Service).
# https://github.com/Nimblesite/SharpLsp
#
# Repackages the upstream standalone release archive. The archive holds a Rust
# host (`sharplsp`) plus two framework-dependent .NET 10 sidecars that the host
# finds next to its own executable.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  dotnet-sdk,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "sharplsp";
  version = "0.33.0";

  src = fetchurl {
    url = "https://github.com/Nimblesite/SharpLsp/releases/download/v${finalAttrs.version}/sharplsp-linux-x64.tar.gz";
    hash = "sha256-/2x9zP7rG0IbQmjfyB9vQyy7nZA0r8zKYMnrgITl2p0=";
  };

  sourceRoot = "sharplsp-linux-x64";

  nativeBuildInputs = [autoPatchelfHook makeWrapper];
  buildInputs = [stdenv.cc.cc.lib];

  # .NET apphosts carry an embedded bundle marker; stripping is pointless and risky.
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/sharplsp $out/bin
    cp -r . $out/lib/sharplsp/

    # --set-default: a project's devshell (via envrc) can point DOTNET_ROOT at
    # the SDK its global.json pins; otherwise fall back to our .NET 10 SDK,
    # which the sidecars need at minimum.
    makeWrapper $out/lib/sharplsp/sharplsp $out/bin/sharplsp \
      --set-default DOTNET_ROOT ${dotnet-sdk}/share/dotnet \
      --suffix PATH : ${lib.makeBinPath [dotnet-sdk]}

    runHook postInstall
  '';

  meta = {
    description = "C# and F# language server (Roslyn + FSharp.Compiler.Service)";
    homepage = "https://sharplsp.dev";
    license = lib.licenses.mit;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode lib.sourceTypes.binaryBytecode];
    platforms = ["x86_64-linux"];
    mainProgram = "sharplsp";
  };
})
