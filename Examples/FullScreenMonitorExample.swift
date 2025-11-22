import Cocoa
import MacroVisionKit

@MainActor
@main
final class FullScreenMonitorExampleApp: NSObject, NSApplicationDelegate {
    private var monitorTask: Task<Void, Never>?

    static func main() {
        let app = NSApplication.shared
        let delegate = FullScreenMonitorExampleApp()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Listening for fullscreen space changes... (Press Ctrl+C to exit)")
        monitorTask = Task { [weak self] in
            guard let self = self else { return }
            let stream = await FullScreenMonitor.shared.spaceChanges()
            for await spaces in stream {
                self.render(spaces)
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        monitorTask?.cancel()
    }

    private func render(_ spaces: [FullScreenMonitor.SpaceInfo]) {
        print("\n--- Fullscreen Spaces Updated ---")
        if spaces.isEmpty {
            print("No fullscreen applications detected.")
        } else {
            print("Detected fullscreen applications:")
            for space in spaces {
                let screenID = space.screenUUID ?? "Unknown"
                let screenName = FullScreenMonitor.shared.screen(for: space)?.localizedName ?? "Unknown"

                let apps = space.runningApps.isEmpty ? "Unknown" : space.runningApps.joined(separator: ", ")
                print("- Screen UUID: \(screenID)")
                print("- Screen Name: \(screenName)")
                print("- Apps: \(apps)")
            }
        }
        fflush(stdout)
    }
}
