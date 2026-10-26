<p align="center">
  <img src="ClipboardCleaner/Assets.xcassets/AppIcon.appiconset/icon_128x128@2x.png" width="112" height="112" alt="Clipboard Cleaner app icon">
</p>

<h1 align="center">Clipboard Cleaner</h1>
<p align="center">One click. Clean clipboard. No clutter.</p>

## Features

- **Delete Clipboard** clears the active system clipboard.
- **Close App** quits the app.
- A native menu bar app with no Dock icon, tracking, network connections, or clipboard history.

<p align="center">
  <img src="docs/images/screenshot.png" width="360" alt="Clipboard Cleaner with Delete Clipboard and Close App buttons">
</p>

## Download & Installation

1. [Download the macOS ZIP](https://github.com/Ryukanchi/ClipboardCleaner/releases/download/v1.0.0/ClipboardCleaner-v1.0.0-macOS-unnotarized.zip) and unzip it.
2. Move **ClipboardCleaner.app** to **Applications**, then open it.

**This build is ad hoc signed, without Apple Developer ID signing or notarization. macOS may block it.** If you trust the source and choose to proceed, follow [Apple's official instructions](https://support.apple.com/en-us/102445) for an app-specific exception in **System Settings → Privacy & Security → Open Anyway**. Keep system security protections enabled.

Optional: add the installed app under **System Settings → General → Login Items → Open at Login** (called **Login Items & Extensions** on newer macOS versions).

## Requirements

macOS 13 or later. Apple Silicon or Intel Mac.

## Build from Source

Open `ClipboardCleaner.xcodeproj` in Xcode, select **ClipboardCleaner** and **My Mac**, then build and run.

## Privacy

Only the active clipboard is cleared, and only when you click **Delete Clipboard**. Copies in clipboard managers, other apps, or other devices may remain. The app does not read or store clipboard contents.

## License

[MIT](LICENSE). Copyright © 2026 Ryukanchi.
