#!/usr/bin/env bash
# Sanity-checks detection against a scratch fixture project, without
# touching your real ~/.config/nvim/lazyvim.json.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/fixture-python" "$TMP/fixture-nvim-config"
touch "$TMP/fixture-python/pyproject.toml"

echo "== detect python fixture =="
NVIM_CONFIG="$TMP/fixture-nvim-config" "$DIR/scripts/detect-and-enable.sh" "$TMP/fixture-python"

if grep -q 'lazyvim.plugins.extras.lang.python' "$TMP/fixture-nvim-config/lazyvim.json"; then
  echo "OK: python extra correctly detected and written"
else
  echo "FAIL: python extra not found in output lazyvim.json" >&2
  exit 1
fi

echo "== idempotency check (re-run should not duplicate) =="
BEFORE=$(wc -l < "$TMP/fixture-nvim-config/lazyvim.json")
NVIM_CONFIG="$TMP/fixture-nvim-config" "$DIR/scripts/detect-and-enable.sh" "$TMP/fixture-python" >/dev/null
AFTER=$(wc -l < "$TMP/fixture-nvim-config/lazyvim.json")
if [ "$BEFORE" = "$AFTER" ]; then
  echo "OK: re-run did not change the file"
else
  echo "FAIL: re-run changed line count ($BEFORE -> $AFTER)" >&2
  exit 1
fi

echo "All checks passed."
