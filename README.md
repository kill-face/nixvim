# Nixvim

Neovim set up as a Rider-style .NET IDE, with key bindings that follow
`~/.ideavimrc` (see `config/keymaps.nix`, kept in the same order).

| Rider piece | Here |
|---|---|
| ReSharper/Rider code intelligence | [SharpLsp](https://sharplsp.dev) (Roslyn for C#, FCS for F#) on Neovim's LSP client |
| Unit test runner | easy-dotnet.nvim test tree + gutter signs, run/debug from buffer |
| Debugger | nvim-dap + dap-ui + netcoredbg (via easy-dotnet), inline values |
| Run configurations, NuGet, solution mgmt, user secrets | easy-dotnet.nvim (`:Dotnet …`) |
| Reformat Code | `dotnet format whitespace` (.editorconfig), CSharpier if the repo uses it, Fantomas for F# |
| Code Cleanup / Inspect Code | JetBrains ReSharper CLI (`jb`) |
| Database tools (DataGrip) | nvim-dbee: connections drawer, SQL editor, paginated results grid (SQL Server, Postgres, SQLite, …) |
| Search Everywhere / Go to | snacks.nvim picker |
| Project view | snacks explorer |
| Problems / TODO / Find | trouble.nvim |
| Structure | aerial.nvim |
| VCS | jj.nvim (log, describe, new, squash, rebase, bookmarks, push), gitsigns |
| Diff viewer, file history | diffview.nvim, with word-level changes highlighted |
| Tabs | bufferline (pin, reorder) |
| easymotion / surround | flash.nvim / nvim-surround |

## Building and deploying

1. `nix build .` (or `nix run .` to try it)
2. `jj git fetch` first if you've pushed from another machine, then `jj git push`
3. In `~/nix/nixos`: `nix flake update nixvim-custom`
4. `sudo nixos-rebuild switch --flake ".#system-name"`

All tools (SharpLsp, easy-dotnet server, netcoredbg, ReSharper CLI, .NET 10 SDK,
formatters) come from Nix. Nothing is `dotnet tool install`ed at runtime.

## Keys

Leader is `Space`. Bindings match `~/.ideavimrc`. As in IdeaVim, a key that is
also a prefix (`<leader>w` SaveAll vs `<leader>wb`, `<leader>as` Stop vs
`<leader>asv`) fires after a 300ms pause. which-key shows what's available after `Space`.

Additions on top of the ideavimrc:

- **Rider debugger keys:** `F8` over, `F7` into, `S-F8` out, `F9` resume, `C-F8`
  breakpoint, `S-F9` debug, `C-F2` stop, `M-F8` evaluate, `M-F9` run to cursor.
- **`M-CR`:** Alt+Enter (code actions).
- **In test files** (buffer-local, from easy-dotnet): `<leader>xt` run test under
  cursor, `<leader>xc` run file, `<leader>dt` debug test, `<leader>xp` peek
  output/stack trace. The same keys work in the test runner window
  (`<leader>wu`), plus `<leader>xa` run all, `<leader>gd` go to test, `]f`/`[f`
  next/previous failure.
- **ReSharper CLI:** `<leader>rc` Code Cleanup on the file, `<leader>rI`
  InspectCode on the solution (results in the quickfix list).
- **Markdown preview:** `<leader>mp` toggles; ideavim's `<leader>amvp` /
  `<leader>amve` open / close it.
- **Diffs** (diffview): `<leader>wvd` opens or closes the diff of the current
  jj change against its parent, `<leader>wvh` / `<leader>wvH` show the history of
  the file / repo. Inside: `<Tab>`/`<S-Tab>` next/previous file, `]c`/`[c`
  next/previous hunk, `g?` all keys. `:DiffviewOpen <commit>^!` shows another
  change (use the commit hash from `jj log`; diffview only knows git).
- **Conflicts** (jj-diffconflicts): `jj resolve` opens Neovim on each
  conflicted file with a two-way diff of the sides, and a second tab
  (`gt`) shows each side against the common base. Edit the left pane into
  the result, then `:w` and `:qa` to accept, or `:cq` to give up on that file. In a
  normal session, `<leader>wvm` does the same for the current buffer (no
  history tab): edit the left pane, `:w`, then `<C-w>o` to close the other one.
  Usual jj flow: `jj new <conflicted change>`, resolve, `jj squash`.
- **`<leader>ss`** (Console.Execute) runs the SQL statement in `.sql` buffers
  and sends to F# Interactive elsewhere.

Not mapped (no equivalent set up): injected-language editing (`eid`, `eif`),
`dm` mark object, `ir` rendered docs, `arv` reload (the config is immutable).

## Database (nvim-dbee)

| ideavim | Rider action | Here |
|---|---|---|
| `<leader>ws` | ActivateDatabaseToolWindow | open/close dbee (drawer, editor, results) |
| `<leader>acds` | ChooseDataSource | pick the active connection |
| `<leader>acs` | ChooseSchema | switch database on the connection |
| `<leader>es` | Console.Execute | run the selection, or the statement under the cursor (block between blank lines / `GO`), in any buffer |
| `<leader>adr` | DatabaseView.Refresh | refresh the drawer |

In the dbee editor, `BB` runs the selection or the whole note. In the results,
`L`/`H` page, `yaj`/`yac` yank rows as JSON/CSV. The drawer lists its own keys.

Connections live outside the Nix store: in
`~/.local/state/nvim/dbee/persistence.json` (the drawer's add/edit writes here)
or `$DBEE_CONNECTIONS`, both a JSON list:

```json
[
  {
    "id": "dev",
    "name": "dev",
    "type": "sqlserver",
    "url": "sqlserver://app:{{ env `DEV_DB_PASS` }}@db.example:1433?database=App"
  }
]
```

`{{ env … }}` and `{{ exec … }}` keep secrets out of the file, e.g.
``{{ exec `cat /run/secrets/dev-db-pass` }}`` with sops-nix. For Windows/AD
logins from Linux, dbee's SQL Server driver includes Kerberos integrated auth
(`authenticator=krb5` plus a krb5 config). Entra ID (Azure AD) auth is not
compiled in.

## .NET notes

- **Debugging.** `<leader>di` debugs the default project (it asks once).
  `<leader>ds` picks a launch profile, `<leader>dan` attaches to a process.
  netcoredbg is weaker than Rider's debugger: no `[DebuggerDisplay]`, no async
  call stacks, and a limited expression evaluator.
- **Refactorings** are Roslyn's: `<leader>rr`, `rm`, `rv`, `rf`, `rs`. Dialog-based
  ones (Change Signature with preview, Move) aren't available over LSP.
- **Over SSH**, yanks go to your local clipboard via OSC 52. Paste with the
  terminal's own paste key, or `p` for Neovim's last yank.
