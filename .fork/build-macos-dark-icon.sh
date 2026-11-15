#!/usr/bin/env bash
# Build the macOS application locally with the fork's Icon Composer artwork.
# Uses no signing identity, Apple Developer account, notarization, or update feed.
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$root"

if [ "$(uname -s)" != Darwin ]; then
  echo "fork build: macOS is required" >&2
  exit 1
fi
if [ "$(uname -m)" != arm64 ]; then
  echo "fork build: Apple Silicon is required for the mac-arm64 target" >&2
  exit 1
fi
if [ ! -d node_modules ]; then
  echo "fork build: run pnpm install first" >&2
  exit 1
fi

bash .fork/apply-overlay.sh
exec pnpm run package:desktop:mac:arm64:unsigned
