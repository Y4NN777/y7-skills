---
name: y7vim-lazyclaude
description: "Install the lazyclaude CLI and lazyclaude.nvim: a lazygit-style floating TUI for browsing and editing Claude Code's on-disk config (skills, agents, MCP servers, hooks, CLAUDE.md) from inside Neovim."
version: 1.0.0
---

# y7vim-lazyclaude

Installs two separate things that work together:

1. [`lazyclaude`](https://github.com/idossha/lazyclaude) — a standalone
   Rust CLI, a lazygit-style TUI for Claude Code's config.
2. [`lazyclaude.nvim`](https://github.com/idossha/lazyclaude.nvim) — wraps
   that CLI in a Neovim floating window, the way `lazygit.nvim` wraps
   `lazygit`.

This is a config-management tool, not a chat tool — see `y7vim-claudecode`
for live chat/diff-review. They coexist with no keymap collision
(`<leader>a*` vs `<leader>lc`).

## Install

```sh
scripts/install-lazyclaude-cli.sh   # cargo install lazyclaude, idempotent
scripts/add-plugin-spec.sh          # writes lua/plugins/lazyclaude.lua
scripts/verify.sh
```

## Keymap / commands

| Keymap | Action |
|---|---|
| `<leader>lc` | Open the LazyClaude config TUI (floating window) |

Commands: `:LazyClaude`, `:LazyClaudeCurrentProject`, `:LazyClaudeToggle`,
`:LazyClaudeClose`. Full option reference: `references/commands.md`.

## Sources used

- [idossha/lazyclaude](https://github.com/idossha/lazyclaude) (CLI)
- [idossha/lazyclaude.nvim](https://github.com/idossha/lazyclaude.nvim) (plugin)

Pinned versions this was built/tested against: `../../sources.yml`.
