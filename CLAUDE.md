# CLAUDE.md

Rules for Claude Code when working in this repo. This is Y4NN777's
personal skills collection — built and refined over time, not a one-off
delivery. Optimize for "still makes sense in six months," not "looks done
right now."

## Before adding or changing a skill

1. Read `CONVENTIONS.md` and follow its layout, naming, and script rules
   exactly. Don't invent a new shape per skill.
2. Never claim a fact about an upstream tool (a command exists, a flag
   does X, a file is at path Y) without having actually read the source,
   run the command, or fetched the doc in this session. If you can't
   verify it, say so instead of guessing — this repo has already shipped
   one wrong claim once ("claudecode.nvim is keymap-only, no commands")
   that turned out to be false on inspection. Don't repeat that pattern.
3. Any script you write, run before you consider it done. A script that
   "looks correct" is not tested. This repo has already caught two real
   bugs (a `--noplugin` flag that disabled the very plugin a test was
   checking, `set -e` silently dropping loop iterations on an empty
   `grep`) that only surfaced by actually executing the thing.

## When something breaks

Log it in the relevant namespace's `docs/problems-and-workarounds.md`,
using the exact format in `CONVENTIONS.md`. Every entry must be something
that actually happened — not a hypothetical. This file exists because the
user explicitly asked for workarounds and problems to be documented going
forward, not just the happy path.

## Scope discipline

- A skill automates a **manual step**, it doesn't reimplement what the
  underlying tool already does well. (Example: `y7vim-autodetect`
  automates clicking a LazyVim `:LazyExtras` recommendation — it doesn't
  build a competing LSP-detection system.) If asked to add a feature,
  check first whether the upstream tool already solves it before writing
  new logic.
- No telemetry, no usage tracking, no onboarding/consent gates, no
  business-review tooling anywhere in this repo. If a pattern from another
  skills framework (gstack, etc.) is useful as a *shape* (skills/scripts/
  references), copy the shape — never its runtime/business machinery.

## Commits

No co-author attribution line in commits to this repo — the user has
asked for this explicitly for this repo. Author identity: `Y4NN777
<axel.studiesmail@gmail.com>`.

## Composing over time

This repo grows by addition. A new namespace or skill should not require
rewriting an existing one. If a shared convention needs to change, update
`CONVENTIONS.md` first and say so in the commit, then apply it going
forward — don't silently retrofit old skills in the same commit unless
asked.
