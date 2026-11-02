#!/usr/bin/env bash
# Thin wrapper: runs the shared headless test suite and filters to the
# claudecode.nvim sections only.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
"$DIR/scripts/test-config.sh" 2>&1 | awk '
  /^== claudecode\.nvim/,/^$/ { print }
  /^== claudecode\.nvim Ex-commands/,/^$/ { print }
'
