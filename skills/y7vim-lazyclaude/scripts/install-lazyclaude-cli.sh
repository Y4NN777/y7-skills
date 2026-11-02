#!/usr/bin/env bash
# Idempotent: installs the lazyclaude CLI via cargo (preferred, no sudo)
# or brew if cargo is unavailable.
set -euo pipefail

if command -v lazyclaude >/dev/null 2>&1; then
  echo "lazyclaude already installed: $(lazyclaude --version)"
  exit 0
fi

if command -v cargo >/dev/null 2>&1; then
  cargo install lazyclaude
elif command -v brew >/dev/null 2>&1; then
  brew install idossha/lazyclaude/lazyclaude
else
  echo "Neither cargo nor brew found. Install one, or build from source:" >&2
  echo "  git clone https://github.com/idossha/lazyclaude && cd lazyclaude && cargo install --path ." >&2
  exit 1
fi

echo "Installed: $(lazyclaude --version 2>&1 || echo 'lazyclaude (version check failed, verify PATH)')"
