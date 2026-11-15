# Fork overlay: macOS Icon Composer artwork

This directory holds the fork-only changes that make the macOS build use an
[Icon Composer](https://developer.apple.com/documentation/xcode/creating-your-app-icon-using-icon-composer)
document instead of the flattened `apps/desktop/resources/icon-macos.png`.

`icon-macos.icon/` is the Icon Composer document. It carries light, dark, and
tinted appearances.

## How the overlay works

Upstream `apps/desktop/scripts/electron-builder-config.mjs` points `mac.icon` at
the PNG. The overlay applies two build-time changes, leaving all upstream-owned
files untouched on the fork branch so upstream tags merge without conflicts:

1. copies `icon-macos.icon/` to `apps/desktop/.desktop-build/fork-icon/`
   (ignored by git);
2. rewrites the `mac.icon` path in `electron-builder-config.mjs` to that copy.

`electron-builder@26.17.0` passes a `.icon` document to `actool`, which emits
`Assets.car` (with the dark and tinted variants) plus a legacy `Icon.icns` for
macOS versions before 26. This needs Xcode 26 or newer (`actool >= 26.0`).
Without the overlay, `mac.icon` stays the flattened PNG and macOS shows the
light artwork in every appearance.

## Local build

```sh
bash .fork/apply-overlay.sh
pnpm install
pnpm run package:desktop:mac:arm64:unsigned
```

The DMG lands in
`apps/desktop/.desktop-build/targets/mac-arm64/unsigned-artifacts/`.
Unsigned builds have an ad-hoc signature and no update feed; macOS may require
approval in System Settings → Privacy & Security before the app opens.

## CI build

`.github/workflows/fork-macos-build.yml` runs daily on `macos-26` and on manual
dispatch. It merges the newest upstream `dsh-v*` tag into the fork branch,
applies this overlay, builds the unsigned arm64 DMG, uploads it as a workflow
artifact, and publishes a `fork-<tag>` GitHub release. Optionally set a
`NOTIFY_WEBHOOK` repository secret to receive a POST after a successful build.

Push this branch to your own fork before relying on the workflow. GitHub
disables scheduled workflows on forks until they are enabled once, and again
after 60 days without repository activity; keep the fork active or trigger the
workflow manually.
