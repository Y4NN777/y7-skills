#!/usr/bin/env bash
# Idempotent: adds the ai.claudecode LazyVim extra import to lua/config/lazy.lua
# if it isn't already there. Does not touch anything else in the file.
set -euo pipefail

NVIM_CONFIG="${NVIM_CONFIG:-$HOME/.config/nvim}"
LAZY_LUA="$NVIM_CONFIG/lua/config/lazy.lua"
IMPORT_LINE='    { import = "lazyvim.plugins.extras.ai.claudecode" },'

if [ ! -f "$LAZY_LUA" ]; then
  echo "Not found: $LAZY_LUA (is this a LazyVim config?)" >&2
  exit 1
fi

if grep -q 'lazyvim.plugins.extras.ai.claudecode' "$LAZY_LUA"; then
  echo "Already enabled in $LAZY_LUA, skipping."
  exit 0
fi

# Insert right after the LazyVim import line, before the user "plugins" import.
tmp=$(mktemp)
awk -v line="$IMPORT_LINE" '
  { print }
  /"LazyVim\/LazyVim", import = "lazyvim.plugins"/ { print line }
' "$LAZY_LUA" > "$tmp"

if ! grep -q 'lazyvim.plugins.extras.ai.claudecode' "$tmp"; then
  echo "Could not find the LazyVim import anchor line in $LAZY_LUA — edit manually." >&2
  rm -f "$tmp"
  exit 1
fi

mv "$tmp" "$LAZY_LUA"
echo "Added ai.claudecode extra to $LAZY_LUA"
echo "Run: nvim --headless '+Lazy! sync' +qa   (to install it)"
