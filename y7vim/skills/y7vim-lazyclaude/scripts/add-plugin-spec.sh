#!/usr/bin/env bash
# Idempotent: drops the lazyclaude.nvim plugin spec into lua/plugins/.
# Safe to re-run; it just overwrites its own managed file.
set -euo pipefail

NVIM_CONFIG="${NVIM_CONFIG:-$HOME/.config/nvim}"
TARGET="$NVIM_CONFIG/lua/plugins/lazyclaude.lua"

if [ ! -d "$NVIM_CONFIG/lua/plugins" ]; then
  echo "Not found: $NVIM_CONFIG/lua/plugins (is this a LazyVim config?)" >&2
  exit 1
fi

cat > "$TARGET" <<'LUA'
return {
  "idossha/lazyclaude.nvim",
  cmd = { "LazyClaude", "LazyClaudeCurrentProject", "LazyClaudeToggle", "LazyClaudeClose" },
  keys = {
    { "<leader>lc", "<cmd>LazyClaude<cr>", desc = "LazyClaude (Claude Code config TUI)" },
  },
  config = function()
    -- lazyclaude defaults to ~/.claude, but if this machine's Claude Code
    -- session sets CLAUDE_CONFIG_DIR to something else (e.g. ~/.aclaude),
    -- the TUI would otherwise show a different, possibly stale config than
    -- the one actually driving the session. Respect it when set.
    require("lazyclaude").setup({
      claude_dir = vim.env.CLAUDE_CONFIG_DIR or vim.fn.expand("~/.claude"),
    })
  end,
}
LUA

echo "Wrote $TARGET"
echo "Run: nvim --headless '+Lazy! sync' +qa   (to install the plugin)"
