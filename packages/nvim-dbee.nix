# nvim-dbee with its Go backend patched to keep the call log (query history)
# per user. Upstream hardcodes /tmp/dbee-calllog.json, which breaks the second
# user on a shared machine and is world-readable. See dbee-calllog-path.go.
{
  lib,
  vimPlugins,
}: let
  upstream = vimPlugins.nvim-dbee;

  dbee-bin = upstream.passthru.dbee-bin.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace handler/handler.go \
          --replace-fail 'const callLogFileName = "/tmp/dbee-calllog.json"' \
                         'var callLogFileName = callLogPath()'
        cp ${./dbee-calllog-path.go} handler/calllog_path.go
      '';
  });
in
  upstream.overrideAttrs (old: {
    # same as upstream's, but pointing at the patched backend
    postPatch = ''
      substituteInPlace lua/dbee/install/init.lua \
        --replace-fail 'return vim.fn.stdpath("data") .. "/dbee/bin"' 'return "${dbee-bin}/bin"'
    '';
    preFixup = ''
      mkdir $target/bin
      ln -s ${lib.getExe dbee-bin} $target/bin/dbee
    '';
    passthru = old.passthru // {inherit dbee-bin;};
  })
