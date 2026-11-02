# Problems & workarounds

A running log, one entry per real issue actually hit while building and
testing this repo — not hypothetical ones. Grows every time something new
breaks.

Format:

```md
## <short title>
**Symptom:** what you saw
**Cause:** what was actually wrong (verified, not guessed)
**Fix:** the exact command/change
**How we caught it:** which test or check surfaced it
```

---

## Headless `qa` cuts Mason's background installer short

**Symptom:** `tree-sitter-cli` and `shfmt` were silently missing after
`Lazy! sync`, even though the sync itself reported success.
**Cause:** Mason installs packages asynchronously in the background; a
headless `nvim --headless "+Lazy! sync" +qa` exits (`qa`) before those
background jobs finish, silently aborting them.
**Fix:** run the install synchronously in the background with a short
sleep instead of an immediate `qa`, then verify the binaries actually
exist on disk afterward.
**How we caught it:** added an explicit binary-existence check
(`test -x ~/.local/share/nvim/mason/bin/tree-sitter`) to the test suite —
the very first test run had passed clean without checking this at all,
which is itself the lesson: "plugin installed" and "its dependent binaries
installed" are not the same check.

## `--noplugin` on a test script silently disables everything it's testing

**Symptom:** first run of the automated test script produced 16 false
failures (every claudecode.nvim and lazyclaude.nvim check failing).
**Cause:** the script launched nvim with `--noplugin -u init.lua`, which
skips the entire lazy.nvim bootstrap, so no plugin — including the two
being tested — ever loaded.
**Fix:** drop `--noplugin`; just `nvim --headless -c "<lua>" -c "qa"`.
**How we caught it:** re-ran immediately after seeing an implausible
100%-failure result — a total failure like that is itself a signal the
test harness is broken, not the thing under test.

## Doc claimed a plugin's commands don't exist, when they're just lazy-loaded

**Symptom:** `vim.fn.getcompletion('ClaudeCode', 'cmdline')` returned an
empty list on a fresh headless session, leading to a documented (wrong)
claim that claudecode.nvim is "keymap-only by design, no Ex-commands."
**Cause:** the plugin is lazy-loaded on its `<leader>a*` keys (LazyVim's
`keys = {...}` spec field). A fresh session that never pressed one of those
keys correctly has zero commands registered — that's expected lazy-loading
behavior, not a design limitation.
**Fix:** force-load the plugin in the test
(`require('lazy').load({plugins={'claudecode.nvim'}})`) before checking for
commands. 15 `:ClaudeCode*` commands appear once loaded. Corrected the doc.
**How we caught it:** re-verified the claim on request instead of letting
it stand — the original "no commands" note had been written without
actually trying to force a load first.

## `lazyvim.org/extras` doesn't list an extra that exists and works

**Symptom:** the published docs site has no AI extra listed except Avante;
no mention of a Claude Code extra at all.
**Cause:** the docs page appears stale/incomplete relative to the actual
LazyVim repo — `lua/lazyvim/plugins/extras/ai/claudecode.lua` exists,
loads, and works.
**Fix:** none needed functionally — just don't treat the published docs
page as the source of truth. Verify against the installed source tree
(`~/.local/share/nvim/lazy/LazyVim/lua/...`) when the docs page and the
real behavior disagree.
**How we caught it:** cross-referenced the docs-site crawl against a direct
read of the installed repo's extras directory.

## A shell loop under `set -e` silently drops iterations when a grep finds nothing

**Symptom:** `gen-markers-reference.sh` produced a markdown table with
headers but zero data rows, no error printed.
**Cause:** `set -euo pipefail` plus a bare `grep -oE ... | ...` assignment
— when the pattern matches nothing, `grep` exits 1, which (under `set -e`,
inside a command substitution used as an assignment) aborted that loop
iteration/script silently rather than just leaving the variable empty.
**Fix:** append `|| true` to every `grep`/pipeline assignment inside a
loop that's allowed to legitimately find nothing (several `lang/*.lua`
extras have no `ft = "..."` filetype line, or no `root = {...}` block —
that's valid, not an error).
**How we caught it:** `wc -l` on the generated file showed only the 7
header lines; same bug recurred in `detect-and-enable.sh`'s detection loop
and was fixed the same way after actually running it against a fixture
project and getting exit code 1 with no output.

## A pasted GitHub skill-install URL simply didn't exist

**Symptom:** `npx skills add https://github.com/RuanBuitendag42/.dotfiles
--skill neovim-lazyvim` failed with "Repository not found."
**Cause:** confirmed via `git ls-remote` and `gh auth status` — the
account's GitHub auth was fine, the repo itself does not exist (wrong owner
or repo name in the pasted instructions).
**Fix:** no workaround attempted — reported the 404 back and asked for the
correct URL rather than guessing at alternate spellings.
**How we caught it:** `git ls-remote` against the exact URL, independent of
the `skills` CLI's own error message, to rule out an auth problem before
concluding the repo was simply wrong.
