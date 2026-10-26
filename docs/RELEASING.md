# Release procedure

## Approval boundaries

- Keep the repository private until its owner explicitly approves making it public.
- Keep the GitHub release as a draft until publication is approved.
- Do not enroll in a paid service, purchase certificates, or submit to the Mac App Store without approval.
- Select and add a license only after the owner approves it. Until then, do not describe the project as open source.
- Do not attach an ad hoc signed or unsigned app to a release.

## Source release

1. Review every tracked file and commit metadata for credentials, personal information, and build products. `.gitignore` does not remove tracked files or old history.
2. Confirm that `main` and the annotated `v1.0.0` tag identify the reviewed release commit. Both Xcode configurations must use marketing version `1.0.0`, build `1`.
3. Build the universal Release configuration using the README command. Verify version, deployment target, both architectures, entitlements, and bundled icon.
4. Run a manual smoke test: launch without clearing, open the menu, clear disposable text and image clipboard data, repeat on an empty clipboard, and quit. Preserve the user's clipboard before testing. Record actual results; a successful build is not a UI test.
5. Verify an actual screenshot, README image rendering, release notes, and license status.
6. Create a draft named **Clipboard Cleaner 1.0.0** targeting `v1.0.0`, using `docs/releases/v1.0.0.md`. A source-only release can be approved independently of binary distribution.
7. Obtain explicit approval before publishing the release or changing repository visibility.

## Executable distribution gate

Use an existing, authorized Apple Developer account and Developer ID Application identity. If unavailable, keep the release source-only. Never work around Gatekeeper or ask users to disable it.

1. Build/archive the exact tagged source with Developer ID Application signing, a secure timestamp, Hardened Runtime, and the existing sandbox entitlement. Use the intended team; do not commit local signing credentials.
2. Check **both** slices of the app with `codesign -dvvv --arch arm64` and `codesign -dvvv --arch x86_64`. Require the intended Developer ID authority and team, a secure timestamp, and the runtime flag. Verify the sealed bundle with `codesign --verify --deep --strict --verbose=2`.
3. Submit a ZIP of the signed app with `xcrun notarytool submit --keychain-profile <existing-profile> --wait`. Require **Accepted** and inspect the submission log. Do not create or print credentials in repository files.
4. Run `xcrun stapler staple` on the app, then `xcrun stapler validate`. Require success.
5. Run `spctl --assess --type execute --verbose=4` on the app outside a restricted execution environment. Require acceptance and the expected notarized Developer ID source.
6. Package the stapled app with `ditto -c -k --sequesterRsrc --keepParent`, then extract the final ZIP and repeat signature, ticket, version, architecture, and Gatekeeper checks on the extracted app.
7. Test download, extraction, first launch, clearing, and quit on a clean Mac. The declared minimum OS is macOS 13; confirm compatibility on macOS 13 and Intel hardware before claiming those environments were tested.
8. Generate a SHA-256 checksum for the final ZIP. Attach only that verified ZIP and its checksum after approval, and update README installation instructions to match the actual asset.

Apple reference: [Signing your apps for Gatekeeper](https://developer.apple.com/developer-id/).
