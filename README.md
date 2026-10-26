# Clipboard Cleaner

A tiny native macOS 13+ menu-bar app. Click the clipboard symbol, then **Delete Clipboard** to clear the system clipboard or **Close App** to quit. No Dock icon or main window.

## Build and install

Open `ClipboardCleaner.xcodeproj` in Xcode, select the ClipboardCleaner scheme, and build. For a universal, locally ad-hoc-signed Release build:

```sh
xcodebuild -project ClipboardCleaner.xcodeproj -scheme ClipboardCleaner \
  -configuration Release -destination "generic/platform=macOS" \
  -derivedDataPath build CODE_SIGN_IDENTITY="-" build
```

Copy `build/Build/Products/Release/ClipboardCleaner.app` to `/Applications`, then open it. The bundle ID is `com.clipboardcleaner.ClipboardCleaner`, version 1.0 (1). Set your development team and add AppIcon artwork before distribution; this local build is not notarized or App Store ready.

## Autostart (off by default)

To enable autostart yourself, open **System Settings > General > Login Items > Open at Login**, click **+**, and select `/Applications/ClipboardCleaner.app`. Remove it from that list to disable autostart. The app never registers a login item itself.

## Privacy

The app only clears the general system pasteboard when you click **Delete Clipboard**. It never reads, monitors, stores, logs, or transmits clipboard contents, and it does not clear anything at launch or on a schedule. It uses App Sandbox with no network entitlements. Clearing the current clipboard does not erase copies already saved by other apps or clipboard-history tools, and is not a secure-erasure guarantee.
