#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

mkdir -p "$INSTALL_DIR"
cp cbox "$INSTALL_DIR/cbox"
chmod +x "$INSTALL_DIR/cbox"

if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
  echo "Warning: $INSTALL_DIR is not in your PATH"
  echo "Add it with: export PATH=\"$INSTALL_DIR:\$PATH\""
else
  echo "Installed cbox to $INSTALL_DIR/cbox"
fi
