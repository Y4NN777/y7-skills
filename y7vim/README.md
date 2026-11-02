# y7vim

Three composed [Agent Skills](https://github.com/anthropics/skills) for
running Claude Code inside Neovim + LazyVim — install, verify, and
auto-adapt to whatever project you open. One namespace in the
[y7-skills](../) root; see `../CONVENTIONS.md` for the shape every skill
here follows.

| Skill | What it does |
|---|---|
| [`y7vim-claudecode`](skills/y7vim-claudecode/) | Live Claude Code chat/diff-review in a terminal split, via LazyVim's own `ai.claudecode` extra |
| [`y7vim-lazyclaude`](skills/y7vim-lazyclaude/) | A lazygit-style floating TUI for browsing/editing Claude Code's on-disk config (skills, agents, MCP, hooks) |
| [`y7vim-autodetect`](skills/y7vim-autodetect/) | Detects a project's language/tooling and enables the matching LazyVim extra automatically — no `:LazyExtras` picker needed |

Each one is self-contained: its own `SKILL.md`, idempotent install
scripts, a `verify.sh`, and a `references/` folder with the exact
commands/keymaps/markers it uses — sourced directly from the upstream
projects, not from memory. See each skill's `SKILL.md` for details.

## Install a skill

```sh
npx skills add https://github.com/Y4NN777/y7-skills --skill y7vim-claudecode
npx skills add https://github.com/Y4NN777/y7-skills --skill y7vim-lazyclaude
npx skills add https://github.com/Y4NN777/y7-skills --skill y7vim-autodetect
```

Or clone and run each skill's scripts directly — see
[`sources.yml`](sources.yml) for the exact upstream versions this was
built and tested against, and
[`docs/claude-code-integration.md`](docs/claude-code-integration.md) for
how the pieces fit together and what the shared test suite covers.

## Requirements

- Neovim >= 0.11.2 (built with LuaJIT)
- Git >= 2.19.0
- [Claude Code CLI](https://claude.com/claude-code) (`claude`) on `$PATH`
- Rust/cargo or Homebrew, for the `lazyclaude` CLI (only needed for
  `y7vim-lazyclaude`)
- A LazyVim config at `~/.config/nvim` — the official
  [starter](https://github.com/LazyVim/starter) or your own

## Testing

```sh
./scripts/test-config.sh
```

31 automated checks against a live LazyVim config: plugin load, both
Claude integrations' require/keymaps/commands, keymap collisions,
`:checkhealth`, and Mason binary presence. See
[`docs/claude-code-integration.md`](docs/claude-code-integration.md) for
exactly what's covered and what still needs a manual check.

## Known issues & how we fixed them

[`docs/problems-and-workarounds.md`](docs/problems-and-workarounds.md) — a
running log of every real snag hit while building this, kept updated as
the namespace grows.

## Updating pinned versions

```sh
./scripts/check-updates.sh
```

Report-only — diffs `sources.yml` against upstream and never auto-bumps.
Review, edit `sources.yml` by hand, re-run the test suite, commit.
