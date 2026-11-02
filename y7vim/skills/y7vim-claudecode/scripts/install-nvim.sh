#!/usr/bin/env bash
# Idempotent Neovim installer: tarball to ~/.local/opt, symlinked into ~/.local/bin.
# Skips if a sufficient nvim is already on PATH.
set -euo pipefail

MIN_MAJOR=0
MIN_MINOR=11
MIN_PATCH=2

version_ok() {
  local v="$1"
  local major minor patch
  IFS='.' read -r major minor patch <<<"${v#v}"
  if [ "$major" -gt "$MIN_MAJOR" ]; then return 0; fi
  if [ "$major" -eq "$MIN_MAJOR" ] && [ "$minor" -gt "$MIN_MINOR" ]; then return 0; fi
  if [ "$major" -eq "$MIN_MAJOR" ] && [ "$minor" -eq "$MIN_MINOR" ] && [ "$patch" -ge "$MIN_PATCH" ]; then return 0; fi
  return 1
}

if command -v nvim >/dev/null 2>&1; then
  CUR=$(nvim --version | head -1 | awk '{print $2}')
  if version_ok "$CUR"; then
    echo "nvim $CUR already satisfies >= ${MIN_MAJOR}.${MIN_MINOR}.${MIN_PATCH}, skipping install."
    exit 0
  fi
  echo "nvim $CUR is below ${MIN_MAJOR}.${MIN_MINOR}.${MIN_PATCH}, installing a current release."
fi

ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ASSET="nvim-linux-x86_64.tar.gz" ;;
  aarch64|arm64) ASSET="nvim-linux-arm64.tar.gz" ;;
  *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
curl -fL "https://github.com/neovim/neovim/releases/latest/download/${ASSET}" -o "$TMP/nvim.tar.gz"
tar xzf "$TMP/nvim.tar.gz" -C "$TMP"

DIRNAME=$(find "$TMP" -maxdepth 1 -type d -name 'nvim-linux-*' -printf '%f\n')
mkdir -p "$HOME/.local/opt"
rm -rf "$HOME/.local/opt/$DIRNAME"
mv "$TMP/$DIRNAME" "$HOME/.local/opt/"

mkdir -p "$HOME/.local/bin"
ln -sf "$HOME/.local/opt/$DIRNAME/bin/nvim" "$HOME/.local/bin/nvim"

echo "Installed: $("$HOME/.local/bin/nvim" --version | head -1)"
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) echo "NOTE: $HOME/.local/bin is not on PATH. Add it to your shell rc." ;;
esac
