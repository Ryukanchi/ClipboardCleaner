# Release procedure

## Current distribution

ClipboardCleaner is a [public repository](https://github.com/Ryukanchi/ClipboardCleaner) licensed under [MIT](../LICENSE). Published macOS apps are universal Release builds with **ad hoc signing, App Sandbox, and Hardened Runtime**. They are **not signed with Apple Developer ID and are not notarized**.

The current release is [v1.0.1](https://github.com/Ryukanchi/ClipboardCleaner/releases/tag/v1.0.1), version **1.0.1 (2)**. Its [release notes](releases/v1.0.1.md) record the assets, checksum, and verification limits. The app was built from `7dc8e69`; annotated tag `v1.0.1` points to `b5ae53b`, which adds only the README download-link update.

This procedure records the process used for the existing releases. For a future release, use a **new, approved version** and reviewed source. Do not repeat publication against an existing tag or release. **Never modify v1.0.0: its tag, release notes, and assets must remain unchanged.** Preserve other published tags and releases as well. Never force-push, move tags, use `git push --tags`, or replace existing assets.

## Prepare the source

1. Work from a clean, reviewed release commit. Review the diff and commit metadata for credentials, unintended files, and build products.
2. In **both target configurations** in [project.pbxproj](../ClipboardCleaner.xcodeproj/project.pbxproj), set `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` to the approved version/build. Current values are `1.0.1` and `2`. A documentation-only update does not require a version bump.
3. Keep the existing bundle identifier, macOS 13 deployment target, universal Release architectures, icon, sandbox entitlement, and Hardened Runtime. Do not commit signing credentials.
4. Prepare repository release notes and the README download link. Record the build commit; if a later commit changes only documentation, make that provenance explicit.

## Build and verify the app

Run from the repository root with Xcode installed. This generic macOS destination and ad hoc identity were used successfully for the universal release; selecting only the host destination can produce a single-architecture build.

```sh
xcodebuild -project ClipboardCleaner.xcodeproj \
  -scheme ClipboardCleaner -configuration Release \
  -destination 'generic/platform=macOS' \
  -derivedDataPath build/release -jobs 1 \
  CODE_SIGN_IDENTITY="-" build
```

Use the following blocks in the same shell and stop at any failed command. They use fresh staging paths under `build/release`. The version/build below identify v1.0.1; use newly approved values for a future release.

```sh
cc_version=1.0.1
cc_build=2
cc_root=build/release
cc_app="$cc_root/Build/Products/Release/ClipboardCleaner.app"
cc_asset="ClipboardCleaner-v$cc_version-macOS-unnotarized.zip"

/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$cc_app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$cc_app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' "$cc_app/Contents/Info.plist"
lipo -archs "$cc_app/Contents/MacOS/ClipboardCleaner"
otool -l "$cc_app/Contents/MacOS/ClipboardCleaner"
codesign --verify --deep --strict "$cc_app"
codesign -dv --verbose=4 "$cc_app"
codesign -d --entitlements - "$cc_app"
otool -L "$cc_app/Contents/MacOS/ClipboardCleaner"
```

Require the approved version/build, **arm64 and x86_64**, minimum macOS **13.0** in the plist and both Mach-O slices, a valid ad hoc signature with the `runtime` flag, and only `com.apple.security.app-sandbox = true`. Dependencies must remain system libraries/frameworks. Check the icon and record actual results.

Smoke-test the exact executable path, rather than an ambiguous app name or bundle-ID lookup. Confirm the running PID/path/version, accessory activation policy, no clearing at launch, no network sockets, and near-zero idle CPU. Back up existing clipboard data only in RAM, use disposable test data, and restore the backup without logging its contents.

Where real UI access is available, test **Delete Clipboard**, the brief green **✓ Cleared!** state and reset, repeated clicks, empty clipboard, and **Close App**. Record real UI tests separately from API-only checks. A successful build or direct `NSPasteboard.general.clearContents()` test does not prove button or animation behavior. Do not claim macOS 13, Intel hardware, or a clean-Mac first launch was tested unless it actually was.

## Package the app and MIT license

Stop if the staging paths or ZIP already exist; do not overwrite a release package. The layout puts **ClipboardCleaner.app** and **LICENSE** directly in the ZIP root, matching the published releases. Ditto may also include `__MACOSX` metadata.

```sh
test ! -e "$cc_root/package"
test ! -e "$cc_root/assets"
mkdir -p "$cc_root/package" "$cc_root/assets"
ditto "$cc_app" "$cc_root/package/ClipboardCleaner.app"
ditto LICENSE "$cc_root/package/LICENSE"
ditto -c -k --sequesterRsrc "$cc_root/package" "$cc_root/assets/$cc_asset"

(cd "$cc_root/assets" && shasum -a 256 "$cc_asset" > "$cc_asset.sha256")
zipinfo -1 "$cc_root/assets/$cc_asset"
```

The checksum asset is named `ClipboardCleaner-v<version>-macOS-unnotarized.zip.sha256`. Its single line contains **64 lowercase hexadecimal characters, two spaces, the ZIP basename, and a newline**. Generate it from the final ZIP, not the executable. Do not add `--keepParent` to the package-directory command: the package directory itself must not wrap the ZIP contents.

Extract into a fresh directory and verify the packaged app, every bundle file, and license:

```sh
test ! -e "$cc_root/roundtrip"
mkdir "$cc_root/roundtrip"
ditto -x -k "$cc_root/assets/$cc_asset" "$cc_root/roundtrip"
codesign --verify --deep --strict "$cc_root/roundtrip/ClipboardCleaner.app"
diff -r "$cc_app" "$cc_root/roundtrip/ClipboardCleaner.app"
cmp LICENSE "$cc_root/roundtrip/LICENSE"
```

Repeat version/build, architecture, minimum-OS, runtime, and entitlement checks on the extracted app. Require the bundle to match the tested build and the MIT license to be present.

## Publish only after approval

Before publishing, present the commits/diff, artifact hashes, actual test results and limitations, README change, and exact release text for approval.

For a **new** approved release, ensure `main` contains the reviewed final commit, then push that branch and only its new annotated tag. Stop if a tag/release already exists or a push is rejected. The variables below continue the preparation blocks; do not run them for the already published v1.0.0 or v1.0.1.

```sh
cc_commit=$(git rev-parse HEAD)
test "$cc_commit" = "$(git rev-parse main)"
git push origin main
git tag -a "v$cc_version" "$cc_commit" -m "Clipboard Cleaner $cc_version"
git push origin "v$cc_version"
gh release create "v$cc_version" \
  "$cc_root/assets/$cc_asset" "$cc_root/assets/$cc_asset.sha256" \
  --repo Ryukanchi/ClipboardCleaner \
  --title "Clipboard Cleaner $cc_version" \
  --notes-file "docs/releases/v$cc_version.md" --verify-tag --latest
```

The release includes the ZIP and checksum, an explicit **ad hoc signed / not notarized** warning, the [Apple Open Anyway instructions](https://support.apple.com/en-us/102445), the ZIP SHA-256, the MIT license notice, and truthful test limitations. Keep system security protections enabled. Updating repository documentation does not authorize editing an existing release body or assets.

## Verify the public download

Use unauthenticated HTTPS downloads and a fresh directory:

```sh
cc_url="https://github.com/Ryukanchi/ClipboardCleaner/releases/download/v$cc_version"
test ! -e "$cc_root/public"
mkdir "$cc_root/public"
curl -fsSL "$cc_url/$cc_asset" -o "$cc_root/public/$cc_asset"
curl -fsSL "$cc_url/$cc_asset.sha256" -o "$cc_root/public/$cc_asset.sha256"
(cd "$cc_root/public" && shasum -a 256 -c "$cc_asset.sha256")
ditto -x -k "$cc_root/public/$cc_asset" "$cc_root/public/extracted"
codesign --verify --deep --strict "$cc_root/public/extracted/ClipboardCleaner.app"
diff -r "$cc_app" "$cc_root/public/extracted/ClipboardCleaner.app"
cmp LICENSE "$cc_root/public/extracted/LICENSE"
curl -fsSL https://raw.githubusercontent.com/Ryukanchi/ClipboardCleaner/main/README.md \
  -o "$cc_root/public/README.md"
cmp README.md "$cc_root/public/README.md"
```

Verify version/build, executable hash, architectures, minimum OS, runtime, and entitlements again. Confirm the release page is public, the intended tag targets the approved commit, the README points to the published asset, and previous tags/releases are unchanged. HTTPS verification alone does not simulate browser quarantine or a clean Mac's first-launch behavior.

## Future (not currently possible: no Developer ID)

At the documentation review on **2026-11-13**, `security find-identity -v -p codesigning` reported **0 valid identities** on the release Mac. No Developer ID Application identity was available. Developer ID signing and notarization are not part of the current distribution process; do not describe existing assets as notarized.

A future Developer ID workflow needs an authorized developer account, signing identity and notarization credentials, followed by signed builds, accepted notarization, stapling, Gatekeeper verification, and clean-Mac testing. See [Apple's Developer ID guidance](https://developer.apple.com/developer-id/). Keep credentials out of the repository.

Mac App Store distribution is a separate future workflow requiring its own account, signing/provisioning, submission, and review. No App Store submission is part of this release procedure. Obtain explicit approval before purchasing services, creating credentials, or submitting.
