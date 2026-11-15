package handler

// Added by ~/nix/standalones/nixvim (packages/nvim-dbee.nix).
//
// Upstream keeps the call log (query history) in a fixed, shared
// /tmp/dbee-calllog.json: on a multi-user machine the first user owns it
// (others get "permission denied") and it is world-readable. Keep it in the
// user's cache dir instead.

import (
	"os"
	"path/filepath"
	"strconv"
)

func callLogPath() string {
	dir, err := os.UserCacheDir() // $XDG_CACHE_HOME or ~/.cache
	if err != nil {
		return filepath.Join(os.TempDir(), "dbee-calllog-"+strconv.Itoa(os.Getuid())+".json")
	}
	path := filepath.Join(dir, "nvim", "dbee", "calllog.json")
	_ = os.MkdirAll(filepath.Dir(path), 0o700)
	return path
}
