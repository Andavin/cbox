#!/usr/bin/env bash
set -euo pipefail

for dockerfile in Dockerfile.*; do
  profile="${dockerfile##*.}"
  echo "Building cbox-$profile..."
  docker build -f "$dockerfile" -t "cbox-$profile" .
done
