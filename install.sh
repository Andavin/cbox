#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${INSTALL_DIR:-}" ]]; then
  # Explicit override — use as-is
  :
elif echo "$PATH" | tr ':' '\n' | grep -qx "$HOME/.local/bin"; then
  INSTALL_DIR="$HOME/.local/bin"
elif echo "$PATH" | tr ':' '\n' | grep -qx "/usr/local/bin"; then
  INSTALL_DIR="/usr/local/bin"
else
  INSTALL_DIR="$HOME/.local/bin"
fi

mkdir -p "$INSTALL_DIR"
cp cbox "$INSTALL_DIR/cbox"
chmod +x "$INSTALL_DIR/cbox"

if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
  echo "Installed cbox to $INSTALL_DIR/cbox"
  echo "Warning: $INSTALL_DIR is not in your PATH"
  echo "Add it with: export PATH=\"$INSTALL_DIR:\$PATH\""
else
  echo "Installed cbox to $INSTALL_DIR/cbox"
fi

# Prompt to build Docker images
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
read -rp "Build Docker images now? [Y/n] " answer
if [[ "${answer:-Y}" =~ ^[Yy]$ ]]; then
  "$SCRIPT_DIR/build.sh"
fi
