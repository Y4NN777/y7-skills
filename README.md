# y7-skills

Personal [Agent Skills](https://github.com/anthropics/skills), built and
improved over time as I actually use them to build and break. Each
top-level folder is one *namespace* — a related family of skills for one
area of my toolchain — not a single skill itself.

This repo is the root all of them live under. See
[`CONVENTIONS.md`](CONVENTIONS.md) for the structure every namespace and
skill here follows, and [`CLAUDE.md`](CLAUDE.md) for the rules Claude Code
itself should follow when working in this repo.

## Namespaces

| Namespace | What it covers |
|---|---|
| [`y7vim/`](y7vim/) | Neovim + LazyVim + Claude Code: install, config management, and auto-detecting project tooling |

More get added as I build them — never as a rewrite of what's here, always
alongside.

## Install a skill

```sh
npx skills add https://github.com/Y4NN777/y7-skills --skill <skill-name>
```

Skill names are namespaced (e.g. `y7vim-claudecode`, `y7vim-lazyclaude`,
`y7vim-autodetect`) so they stay unambiguous as more namespaces get added.

## What this repo is not

Not a product, not a team tool, not something with telemetry, onboarding
gates, or business-review layers. Just my own tooling, documented well
enough that future-me (or anyone else) can pick it back up.
