---
name: y7vim-autodetect
description: "Detect a project's language/tooling and enable the matching LazyVim extras automatically, without opening the :LazyExtras picker by hand."
version: 1.0.0
---

# y7vim-autodetect

LazyVim already ships 46 language extras
(`lazyvim/plugins/extras/lang/*.lua`), each wiring the right LSP server +
formatter + treesitter parser for one language. Each extra declares its own
detection via `LazyVim.extras.wants({ ft, root })` — e.g. Python's extra
checks for `pyproject.toml`, `setup.py`, `requirements.txt` (read straight
from the LazyVim source, not guessed).

**The gap this skill fills:** `wants()` only *flags* a recommendation
inside the `:LazyExtras` UI — a starred row you still have to open and
press `x` on, per extra, per project. This skill automates that one click;
it does **not** reimplement LSP detection, write our own language-server
registry, or compete with Mason/lspconfig in any way. If LazyVim has no
extra for a language, this skill can't invent one.

## How it works

`scripts/detect-and-enable.sh <project-dir>` reads the `root = {...}`
marker list directly out of each `extras/lang/*.lua` file in your installed
LazyVim copy (never a hand-maintained duplicate list, so it can't drift out
of sync after an upgrade), matches them against the given project
directory, and merges the matching extra module names into
`~/.config/nvim/lazyvim.json`'s `extras` array — the exact format LazyVim
itself reads/writes (confirmed from `lazyvim/config/init.lua` and
`lazyvim/util/json.lua`, format version 8 at time of writing).

It only ever **adds** to the array — it never removes an extra you already
enabled by hand.

## Install / usage

```sh
scripts/detect-and-enable.sh ~/code/some-python-project
# -> adds "lazyvim.plugins.extras.lang.python" to lazyvim.json if pyproject.toml etc. found

scripts/gen-markers-reference.sh
# -> regenerates references/extra-root-markers.md from the installed LazyVim source
```

### Optional: fully automatic on project open

Add to `lua/config/autocmds.lua` (see `references/autocmd-snippet.lua`):
runs detection on `DirChanged`/`VimEnter` and triggers `:Lazy reload` if
anything new was enabled — so "automatically set the language server when
opened" happens with zero manual step at all, not just zero manual
*picking*.

## Verify

```sh
scripts/verify.sh ~/code/some-project
```

## Sources used

- `lazyvim/util/extras.lua` (`wants()`, `get()`) — detection primitives
- `lazyvim/plugins/extras/lang/*.lua` — the 46 per-language root/ft markers
- `lazyvim/config/init.lua` + `lazyvim/util/json.lua` — `lazyvim.json`
  read/write format

Pinned LazyVim version this was built against: `../../sources.yml`.
