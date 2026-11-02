# claudecode.nvim — full command reference

`claudecode.nvim` is lazy-loaded on the `<leader>a*` keys declared by
LazyVim's `ai.claudecode` extra. That means a **fresh, untouched Neovim
session reports zero `:ClaudeCode*` commands** in `getcompletion()` — this
is expected, not a bug (an earlier draft of our docs claimed the plugin was
"keymap-only by design," which was wrong; see
`../../docs/problems-and-workarounds.md`).

Once loaded (press any `<leader>a*` key once, or force-load it
programmatically), the full command set appears:

| Command | Purpose |
|---|---|
| `:ClaudeCode` | Open/toggle the Claude terminal |
| `:ClaudeCodeStart` | Start the Claude Code session |
| `:ClaudeCodeStop` | Stop the session |
| `:ClaudeCodeOpen` | Open the terminal window |
| `:ClaudeCodeClose` | Close the terminal window |
| `:ClaudeCodeFocus` | Focus the terminal window |
| `:ClaudeCodeStatus` | Show connection/session status |
| `:ClaudeCodeSend` | Send the current selection/context |
| `:ClaudeCodeSendText` | Send arbitrary text |
| `:ClaudeCodeAdd` | Add current buffer to context |
| `:ClaudeCodeTreeAdd` | Add a file-tree selection to context |
| `:ClaudeCodeSelectModel` | Pick which Claude model to use |
| `:ClaudeCodeDiffAccept` | Accept a proposed diff |
| `:ClaudeCodeDiffDeny` | Deny a proposed diff |
| `:ClaudeCodeCloseAllDiffs` | Close all open diff views |

Verified live against the plugin, this conversation, by force-loading it
headless and reading `getcompletion('ClaudeCode', 'cmdline')`.
