---
name: y7vim-claudecode
description: "Install and verify claudecode.nvim: live Claude Code chat and diff review inside a Neovim terminal split, enabled via the official LazyVim extra."
version: 1.0.0
---

# y7vim-claudecode

Installs [claudecode.nvim](https://github.com/coder/claudecode.nvim) by
enabling LazyVim's own `ai.claudecode` extra — no plugin spec of our own,
we just turn on what LazyVim already ships.

## What it needs first

- Neovim >= 0.11.2 (built with LuaJIT)
- Git >= 2.19.0
- The `claude` CLI on `$PATH`
- A LazyVim config at `~/.config/nvim` (starter or your own)

Use `y7vim-lazyvim-bootstrap`-style steps first if none of this exists yet
— see `scripts/install-nvim.sh` in this skill for the Neovim part.

## Install

```sh
scripts/install-nvim.sh        # idempotent: skips if nvim >= 0.11.2 found
scripts/enable-extra.sh        # adds the ai.claudecode import to lua/config/lazy.lua
scripts/verify.sh              # headless checks, see references/
```

## Keymaps (once loaded)

| Keymap | Action |
|---|---|
| `<leader>ac` | Toggle Claude terminal |
| `<leader>ab` | Add current buffer to Claude's context |
| `<leader>af` | Focus the Claude terminal |
| `<leader>ar` | Resume a previous Claude session |
| `<leader>aC` | Continue the last Claude conversation |
| `<leader>aa` | Accept diff (when Claude proposes an edit) |
| `<leader>ad` | Deny diff |

Full command list (only visible after first load — see
`references/commands.md`) and why that's expected, not a bug.

## Sources used

- LazyVim extra: `lazyvim.plugins.extras.ai.claudecode` — exists in the
  installed LazyVim repo (`lua/lazyvim/plugins/extras/ai/claudecode.lua`)
  even though `lazyvim.org/extras` doesn't list it. Verified by reading the
  source file directly, not the docs site — see
  `../../docs/problems-and-workarounds.md`.
- [coder/claudecode.nvim](https://github.com/coder/claudecode.nvim) — pulled
  in by the extra above.

Pinned versions this was built/tested against: `../../sources.yml`.
