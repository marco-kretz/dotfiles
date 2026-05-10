#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/GitHub/dotfiles}"
PACKAGE="pi"
TARGET="$HOME"

if ! command -v stow >/dev/null 2>&1; then
  echo "GNU stow is not installed or not on PATH" >&2
  exit 1
fi

cd "$DOTFILES_DIR"

# If settings.json already exists as a regular file, move it into the stow
# package once so stow can replace it with a symlink.
if [[ -f "$HOME/.pi/agent/settings.json" && ! -L "$HOME/.pi/agent/settings.json" ]]; then
  mkdir -p "$DOTFILES_DIR/pi/.pi/agent"
  cp "$HOME/.pi/agent/settings.json" "$DOTFILES_DIR/pi/.pi/agent/settings.json.backup-before-stow"
  mv "$HOME/.pi/agent/settings.json" "$DOTFILES_DIR/pi/.pi/agent/settings.json"
fi

stow -t "$TARGET" "$PACKAGE"

echo "Stowed $PACKAGE -> $TARGET"
echo "Pi extension symlink: ~/.pi/agent/extensions/explore-codebase/index.ts"
echo "Pi settings symlink:   ~/.pi/agent/settings.json"
