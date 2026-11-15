#!/usr/bin/env bash
# Fork overlay: package macOS with the Icon Composer document instead of the flattened PNG.
# Run from anywhere after checking out a branch that contains .fork/; idempotent.
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_icon="$root/.fork/icon-macos.icon"
target_icon="$root/apps/desktop/.desktop-build/fork-icon/icon-macos.icon"
config="$root/apps/desktop/scripts/electron-builder-config.mjs"

if [ ! -f "$source_icon/icon.json" ] || [ ! -d "$source_icon/Assets" ]; then
  echo "fork overlay: $source_icon is not an Icon Composer document" >&2
  exit 1
fi
if ! command -v actool >/dev/null 2>&1; then
  echo "fork overlay: actool is required (install Xcode 26 or newer and select it with xcode-select)" >&2
  exit 1
fi

rm -rf "$target_icon"
mkdir -p "$(dirname "$target_icon")"
cp -R "$source_icon" "$target_icon"

if grep -q "resources/icon-macos\.png" "$config"; then
  perl -pi -e "s#resources/icon-macos\\.png#.desktop-build/fork-icon/icon-macos.icon#" "$config"
fi
if ! grep -q "\.desktop-build/fork-icon/icon-macos\.icon" "$config"; then
  echo "fork overlay: $config does not reference the Icon Composer document" >&2
  exit 1
fi

echo "fork overlay: macOS packaging uses $target_icon"
