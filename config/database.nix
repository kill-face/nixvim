# Database console (DataGrip / Rider database tools): nvim-dbee. Its Go
# backend is built by nixpkgs and includes the SQL Server driver
# (go-mssqldb, with Kerberos integrated auth).
#
# Connections are read at runtime, never from the Nix store:
#   - ~/.local/state/nvim/dbee/persistence.json (also what the drawer's
#     add/edit actions write to)
#   - $DBEE_CONNECTIONS (same JSON)
# e.g.
#   [{ "id": "dev", "name": "dev", "type": "sqlserver",
#      "url": "sqlserver://app:{{ env `DEV_DB_PASS` }}@db.example:1433?database=App" }]
# `{{ env ... }}` / `{{ exec ... }}` keep secrets out of the file (e.g.
# {{ exec `cat /run/secrets/dev-db-pass` }} with sops-nix).
{...}: {
  plugins.dbee = {
    enable = true;
    settings = {
      # upstream's layout swallows :qa (quit twice); see kf.dbee_layout
      window_layout.__raw = "require('kf').dbee_layout()";
      result.page_size = 200;
      editor.mappings = [
        # Console.Execute (ideavim <leader>es), plus dbee's defaults
        {
          key = "<leader>es";
          mode = "v";
          action = "run_selection";
        }
        {
          key = "<leader>es";
          mode = "n";
          action.__raw = "function() require('kf').db_execute() end";
        }
        {
          key = "BB";
          mode = "v";
          action = "run_selection";
        }
        {
          key = "BB";
          mode = "n";
          action = "run_file";
        }
      ];
    };
  };
}
