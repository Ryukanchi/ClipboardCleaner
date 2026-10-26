import AppKit
import SwiftUI

@main
struct ClipboardCleanerApp: App {
    var body: some Scene {
        MenuBarExtra("Clipboard Cleaner", systemImage: "clipboard") {
            VStack(spacing: 12) {
                Button {
                    NSPasteboard.general.clearContents()
                } label: {
                    Text("Delete Clipboard")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button("Close App") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .controlSize(.small)
                .foregroundStyle(.secondary)
            }
            .padding(16)
            .frame(width: 220)
        }
        .menuBarExtraStyle(.window)
    }
}
