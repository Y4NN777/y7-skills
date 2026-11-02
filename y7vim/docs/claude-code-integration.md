# Claude Code integration in Neovim — reference

This repo wires up two separate, complementary tools, plus a third that
automates project-tooling detection. They don't conflict.

| | y7vim-claudecode | y7vim-lazyclaude | y7vim-autodetect |
|---|---|---|---|
| Purpose | Chat/edit with Claude Code live, in a terminal split | Browse/edit Claude Code's on-disk config | Auto-enable the right LazyVim lang extra per project |
| Backing process | the `claude` CLI, driven over a local WebSocket | the `lazyclaude` Rust CLI | none — writes `lazyvim.json` directly |
| Leader prefix | `<leader>a*` | `<leader>lc` | n/a (runs via script / autocmd) |

See each skill's own `SKILL.md` under `skills/` for install steps and
keymaps. This file covers how they fit together and the cross-skill
testing done against them.

## Shared test suite

`scripts/test-config.sh` is the one shared headless test harness, run
against a live `~/.config/nvim`. Each skill's own `scripts/verify.sh` is a
thin filter over this same suite (`y7vim-claudecode`,
`y7vim-lazyclaude`) or a self-contained fixture test
(`y7vim-autodetect`, which never touches your real config).

It checks, end to end:

- Neovim/git/claude/lazyclaude binary presence and version
- lazy.nvim loads every plugin spec without error
- `require('claudecode')` succeeds; its `<leader>a*` keymaps register;
  its 15 `:ClaudeCode*` Ex-commands appear once force-loaded
- `require('lazyclaude')` succeeds; `is_available()` confirms the CLI is
  visible from inside nvim; its commands and `<leader>lc` keymap register
- No duplicate normal-mode keymaps (collision check across both tools)
- `:checkhealth lazy` reports no blocking errors (missing `luarocks` is an
  explicitly whitelisted non-issue — nothing here declares a rocks
  dependency)
- Mason binaries (`tree-sitter-cli`, `shfmt`) actually exist on disk, not
  just "sync reported success" — see
  [`problems-and-workarounds.md`](problems-and-workarounds.md) for why that
  distinction mattered

Exit code `0` when every check passes, `1` otherwise — CI-friendly.

## What this does *not* test

Headless mode can start claudecode.nvim's WebSocket server and confirm
every command/keymap resolves, but it cannot drive an actual interactive
terminal split or watch a real `claude` process attach end to end. Verify
that last mile by hand:

1. Open `nvim` normally.
2. Press `<leader>ac` — a terminal split should open and launch `claude`.
3. Press `<leader>lc` — a floating window should open showing the
   LazyClaude TUI.

## Known non-issues

- **`luarocks not installed`** — lazy.nvim's optional `lazy-rocks` feature;
  nothing in this setup declares a `rocks` dependency.
- **`:ClaudeCode*` commands missing from a fresh `getcompletion()` call** —
  claudecode.nvim is lazy-loaded on `<leader>a*`; this is expected, not a
  bug. Full command list in `skills/y7vim-claudecode/references/commands.md`.

Full incident log, including the two real test-script bugs found and fixed
while building this: [`problems-and-workarounds.md`](problems-and-workarounds.md).
