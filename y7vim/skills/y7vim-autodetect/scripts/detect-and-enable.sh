#!/usr/bin/env bash
# Detect a project's language/tooling by walking the SAME root-marker
# files LazyVim's own lang extras declare, and merge the matching extras
# into ~/.config/nvim/lazyvim.json. Additive only, never removes.
#
# Usage: detect-and-enable.sh [project-dir]   (defaults to cwd)
set -euo pipefail

PROJECT_DIR="${1:-$PWD}"
NVIM_CONFIG="${NVIM_CONFIG:-$HOME/.config/nvim}"
LAZYVIM_SRC="${LAZYVIM_SRC:-$HOME/.local/share/nvim/lazy/LazyVim}"
EXTRAS_DIR="$LAZYVIM_SRC/lua/lazyvim/plugins/extras/lang"
LAZYVIM_JSON="$NVIM_CONFIG/lazyvim.json"

if [ ! -d "$EXTRAS_DIR" ]; then
  echo "LazyVim source not found at: $EXTRAS_DIR" >&2
  echo "Set LAZYVIM_SRC or run 'Lazy! sync' first." >&2
  exit 1
fi

if [ ! -d "$PROJECT_DIR" ]; then
  echo "Not a directory: $PROJECT_DIR" >&2
  exit 1
fi

MATCHED=()

for f in "$EXTRAS_DIR"/*.lua; do
  name=$(basename "$f" .lua)
  # Pull the root = { "a", "b", ... } list out of the recommended() block.
  # Markers are plain quoted filenames; this is a best-effort grep, not a
  # Lua parser — accurate for every extra as of LazyVim v16.x.
  markers=$(awk '/root = \{/,/\}/' "$f" | grep -oE '"[^"]+"' | tr -d '"' || true)
  if [ -z "$markers" ]; then
    continue
  fi
  while IFS= read -r marker; do
    [ -z "$marker" ] && continue
    if [ -e "$PROJECT_DIR/$marker" ]; then
      MATCHED+=("lazyvim.plugins.extras.lang.$name")
      break
    fi
  done <<< "$markers"
done

if [ "${#MATCHED[@]}" -eq 0 ]; then
  echo "No matching LazyVim lang extras found for: $PROJECT_DIR"
  exit 0
fi

echo "Detected extras for $PROJECT_DIR:"
printf '  %s\n' "${MATCHED[@]}"

python3 - "$LAZYVIM_JSON" "${MATCHED[@]}" <<'PY'
import json, sys, os

path = sys.argv[1]
new_extras = sys.argv[2:]

data = {"version": 8, "install_version": 8, "news": {}, "extras": []}
if os.path.exists(path):
    with open(path) as f:
        try:
            data.update(json.load(f))
        except json.JSONDecodeError:
            print(f"WARNING: {path} is not valid JSON, refusing to overwrite.", file=sys.stderr)
            sys.exit(1)

existing = set(data.get("extras", []))
added = [e for e in new_extras if e not in existing]
data["extras"] = sorted(existing | set(new_extras))

with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")

if added:
    print("Added to " + path + ":")
    for e in added:
        print("  " + e)
else:
    print("Already enabled, no changes to " + path)
PY

echo "Run: nvim --headless '+Lazy! sync' +qa   (to install any newly-added extra's plugins)"
