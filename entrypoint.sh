#!/usr/bin/env bash
set -euo pipefail

# Initialize Bazinga in the workspace if not already done
if [[ ! -d bazinga ]]; then
  uvx --from git+https://github.com/mehdic/bazinga.git bazinga init --here --no-git || true
fi

exec claude --dangerously-skip-permissions "$@"
