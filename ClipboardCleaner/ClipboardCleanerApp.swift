import AppKit
import SwiftUI

@main
struct ClipboardCleanerApp: App {
    var body: some Scene {
        MenuBarExtra("Clipboard Cleaner", systemImage: "clipboard") {
            ClipboardControls()
        }
        .menuBarExtraStyle(.window)
    }
}

private struct ClipboardControls: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var clearRequest: UUID?

    var body: some View {
        let cleared = clearRequest != nil

        VStack(spacing: 12) {
            Button {
                NSPasteboard.general.clearContents()
                clearRequest = UUID()
            } label: {
                Text("Delete Clipboard")
                    .opacity(cleared ? 0 : 1)
                    .overlay {
                        Label("Cleared!", systemImage: "checkmark")
                            .opacity(cleared ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(cleared ? .green : nil)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.12), value: cleared)
            .accessibilityLabel(cleared ? "Cleared!" : "Delete Clipboard")

            Button("Close App") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .controlSize(.small)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(width: 220)
        .task(id: clearRequest) { @MainActor in
            guard let request = clearRequest else { return }
            do {
                try await Task.sleep(nanoseconds: 800_000_000)
            } catch {
                return
            }
            guard !Task.isCancelled, clearRequest == request else { return }
            clearRequest = nil
        }
        .onDisappear {
            clearRequest = nil
        }
    }
}
