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
    require("lazyclaude").setup({})
  end,
}
LUA

echo "Wrote $TARGET"
echo "Run: nvim --headless '+Lazy! sync' +qa   (to install the plugin)"
