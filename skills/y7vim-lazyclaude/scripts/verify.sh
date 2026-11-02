#!/usr/bin/env bash
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
"$DIR/scripts/test-config.sh" 2>&1 | awk '/^== lazyclaude\.nvim/,/^$/ { print }'
