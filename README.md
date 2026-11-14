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
| Search Everywhere / Go to | snacks.nvim picker |
| Project view | snacks explorer |
| Problems / TODO / Find | trouble.nvim |
| Structure | aerial.nvim |
| VCS | jj.nvim (log, describe, new, squash, rebase, bookmarks, push), gitsigns |
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

Not mapped (no equivalent set up): database console (`<leader>acds`, `acs`,
`adr`, `es`), injected-language editing (`eid`, `eif`),
`dm` mark object, `ir` rendered docs, `arv` reload (the config is immutable).

## .NET notes

- **Choosing a solution.** SharpLsp loads the single `.sln`/`.slnx` it finds. If
  there are several, it loads none. Pick one in a `sharplsp.toml` next to them:
  `[csharp]` then `solution_path = "src/MyApp.sln"`.
- **Debugging.** `<leader>di` debugs the default project (it asks once).
  `<leader>ds` picks a launch profile, `<leader>dan` attaches to a process.
  netcoredbg is weaker than Rider's debugger: no `[DebuggerDisplay]`, no async
  call stacks, and a limited expression evaluator.
- **Refactorings** are Roslyn's: `<leader>rr`, `rm`, `rv`, `rf`, `rs`. Dialog-based
  ones (Change Signature with preview, Move) aren't available over LSP.
- **Over SSH**, yanks go to your local clipboard via OSC 52. Paste with the
  terminal's own paste key, or `p` for Neovim's last yank.
