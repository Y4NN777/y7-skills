#!/usr/bin/env bash
# Diffs sources.yml's pinned versions against upstream latest.
# Report-only: never writes to sources.yml. You review and bump by hand.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCES="$ROOT/sources.yml"

latest_tag() {
  # $1 = owner/repo
  gh api "repos/$1/releases/latest" --jq '.tag_name' 2>/dev/null \
    || git ls-remote --tags --refs "https://github.com/$1" 2>/dev/null \
         | awk -F/ '{print $NF}' | sort -V | tail -1
}

check() {
  local label="$1" repo="$2" current="$3"
  local latest
  latest=$(latest_tag "$repo" || echo "unknown")
  if [ "$latest" = "unknown" ] || [ -z "$latest" ]; then
    printf '%-20s %-30s current=%-12s latest=UNKNOWN (check manually)\n' "$label" "$repo" "$current"
  elif [ "$latest" = "$current" ] || [ "v$latest" = "$current" ] || [ "$latest" = "v$current" ]; then
    printf '%-20s %-30s current=%-12s up to date\n' "$label" "$repo" "$current"
  else
    printf '%-20s %-30s current=%-12s latest=%s  <-- UPDATE AVAILABLE\n' "$label" "$repo" "$current" "$latest"
  fi
}

echo "Checking upstream sources against $SOURCES ..."
echo

check "neovim"         "neovim/neovim"          "$(grep -A2 '^neovim:' "$SOURCES" | grep installed_version | grep -oE '"[^"]+"' | tr -d '"')"
check "lazyvim"         "LazyVim/LazyVim"        "$(grep -A2 '^lazyvim:' "$SOURCES" | grep installed_version | grep -oE '"[^"]+"' | tr -d '"')"
check "claudecode.nvim" "coder/claudecode.nvim"  "$(grep -A2 '^claudecode_nvim:' "$SOURCES" | grep installed_version | grep -oE '"[^"]+"' | tr -d '"')"
check "lazyclaude"      "idossha/lazyclaude"     "$(grep -A2 '^lazyclaude_cli:' "$SOURCES" | grep installed_version | grep -oE '"[^"]+"' | tr -d '"')"

echo
echo "Nothing was written. Bump sources.yml by hand, then re-run scripts/test-config.sh."
