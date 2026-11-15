# Fork overlay: macOS Icon Composer artwork

This directory holds the fork-only changes that make the macOS build use an
[Icon Composer](https://developer.apple.com/documentation/xcode/creating-your-app-icon-using-icon-composer)
document instead of the flattened `apps/desktop/resources/icon-macos.png`.

`icon-macos.icon/` is the Icon Composer document. It carries light, dark, and
tinted appearances.

## Local flow

1. Update the checkout yourself (`git pull`, or merge the upstream `dsh-v*` tag
   you want to build).
2. Run `bash .fork/build-macos-dark-icon.sh`.
3. Open the DMG printed by the command and copy the application to
   `/Applications`.

The script applies the overlay and runs the repository's unsigned macOS arm64
packaging. Requirements: an Apple Silicon Mac, Xcode 26 or newer (`actool`),
Node 24, and pnpm 11.28.5 (`pnpm install` once).

## Signing and Gatekeeper

Local packaging uses no code-signing identity, no Apple Developer account, no
notarization, and no update feed. electron-builder strips `CSC_*` and `APPLE_*`
settings and applies only an ad-hoc signature (`codesign -s -`), which Apple
Silicon requires for any modified application to launch. An ad-hoc signature is
not a certificate and is not tied to an account.

A build signed with DeepSeek's official Developer ID cannot be produced
locally: that private key exists only in the release pipeline and is not in this
repository. Modifying an officially signed application would also invalidate
its signature. First launch therefore needs Gatekeeper approval (System
Settings → Privacy & Security → Open Anyway) or:

```sh
xattr -dr com.apple.quarantine "/Applications/DeepSeek Harness.app"
```

## Overlay mechanics

Upstream `apps/desktop/scripts/electron-builder-config.mjs` points `mac.icon` at
the PNG. The overlay applies two build-time changes, leaving all upstream-owned
files untouched on the branch so upstream tags merge without conflicts:

1. copies `icon-macos.icon/` to `apps/desktop/.desktop-build/fork-icon/`
   (ignored by git);
2. rewrites the `mac.icon` path in `electron-builder-config.mjs` to that copy.

`electron-builder@26.17.0` passes a `.icon` document to `actool`, which emits
`Assets.car` (with the dark and tinted variants) plus a legacy `Icon.icns` for
macOS versions before 26. This needs Xcode 26 or newer (`actool >= 26.0`).
Without the overlay, `mac.icon` stays the flattened PNG and macOS shows the
light artwork in every appearance.

## Updating the artwork

Replace the contents of `.fork/icon-macos.icon/` with a new Icon Composer
export. Keep the directory name `icon-macos.icon`; `apply-overlay.sh` and the
config rewrite depend on it.
