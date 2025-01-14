import Cocoa
import MacroVisionKit

// A simple application to demonstrate the usage of MacroVisionKit
class FullscreenDetectorExample {
    
    let detector: MacroVisionKit
    
    init() {
        // Initialize the MacroVisionKit detector
        self.detector = MacroVisionKit.shared
    }
    
    func run() {
        // Detect fullscreen applications
        let fullscreenApps = detector.detectFullscreenApps(debug: true)
        
        // Print detected fullscreen applications
        if fullscreenApps.isEmpty {
            print("No fullscreen applications detected.")
        } else {
            print("Detected fullscreen applications:")
            for appInfo in fullscreenApps {
                print("📱 Application: \(appInfo.name ?? "Unknown")")
                print("   Bundle ID: \(appInfo.bundleIdentifier ?? "No Bundle")")
                print("   Window Size: \(appInfo.windowSize.width) x \(appInfo.windowSize.height)")
                print("   Process ID: \(appInfo.processId)")
            }
        }
    }
}

// Entry point for the application
let detectorExample = FullscreenDetectorExample()
detectorExample.run() 
