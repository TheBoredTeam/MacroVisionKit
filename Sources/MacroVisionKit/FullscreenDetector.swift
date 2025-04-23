import Cocoa
import Foundation

/// MacroVisionKit: Advanced window state detection framework for macOS
/// This framework provides sophisticated functionality for real-time analysis
/// of application window states, with particular emphasis on viewport utilization
/// and screen space optimization detection.
///
/// - Author: github.com/theboringhumane
/// - Version: 1.0.0
public class MacroVisionKit {
    
    /// Singleton instance of MacroVisionKit
    public static let shared = MacroVisionKit()
    
    /// Configuration parameters for window state analysis
    public struct Configuration {
        /// Viewport size tolerance threshold (0.0 to 1.0)
        /// Default is 0.02 (2% tolerance)
        public var sizeTolerance: CGFloat = 0.02
        
        /// Origin tolerance threshhold (in points)
        /// Default is 5.0 points
        public var originTolerance: CGFloat = 5.0
        
        /// Process filtering configuration for system applications
        public var includeSystemApps: Bool = false
        
        public init(sizeTolerance: CGFloat = 0.02, originTolerance: CGFloat = 5.0, includeSystemApps: Bool = false) {
            self.sizeTolerance = sizeTolerance
            self.originTolerance = originTolerance
            self.includeSystemApps = includeSystemApps
        }
    }
    
    /// Active configuration parameters
    public var configuration: Configuration
    
    private init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }
    
    /// Comprehensive information about a detected fullscreen application
    public struct FullscreenWindowInfo {
        /// The active application process
        public let application: NSRunningApplication
        /// Associated display device
        public let screen: NSScreen
        /// Current viewport dimensions
        public let windowFrame: CGRect
        
        /// Application bundle identifier
        public var bundleIdentifier: String? {
            application.bundleIdentifier
        }
        
        /// Application display name
        public var name: String? {
            application.localizedName
        }
        
        /// Process identifier
        public var processId: pid_t {
            application.processIdentifier
        }
    }
    
    /// Performs real-time analysis of application window states
    /// - Parameter debug: Enable diagnostic output for detailed analysis
    /// - Returns: Array of FullscreenAppInfo for detected viewport-maximized applications
    public func detectFullscreenApps(debug: Bool = false) -> [FullscreenWindowInfo] {
        let windowInfoList = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
        let screens = NSScreen.screens
        var fullscreenWindows: [FullscreenWindowInfo] = []
        
        if debug {
            print("🔬 [MacroVisionKit] Analyzing \(windowInfoList.count) on-screen windows...")
        }
        
        for windowInfo in windowInfoList {
            guard let windowID = windowInfo[kCGWindowNumber as String] as? CGWindowID,
                  let ownerPID = windowInfo[kCGWindowOwnerPID as String] as? pid_t,
                  let ownerName = windowInfo[kCGWindowOwnerName as String] as? String,
                  let boundsDict = windowInfo[kCGWindowBounds as String] as? [String: CGFloat],
                  let windowFrame = CGRect(dictionaryRepresentation: boundsDict as CFDictionary),
                  let alpha = windowInfo[kCGWindowAlpha as String] as? CGFloat else { continue }
            guard alpha > 0 else { continue }
            guard let screen = screens.first(where: { $0.frame.contains(windowFrame) }) else { continue }
            let screenFrame = screen.frame
            let sizeMatches = doesSizeMatchScreen(windowFrame: windowFrame, screenFrame: screenFrame)
            let originMatches = doesOriginMatchScreen(windowFrame: windowFrame, screenFrame: screenFrame)
            
            if sizeMatches && originMatches {
                guard let app = NSRunningApplication(processIdentifier: ownerPID) else { continue }
                if !configuration.includeSystemApps, app.bundleIdentifier?.hasPrefix("com.apple.") == true {
                    if debug { print("⏭️ Skipping system app: \(app.localizedName ?? "Unknown")") }
                    continue
                }
                let info = FullscreenWindowInfo(
                    application: app,
                    screen: screen,
                    windowFrame: windowFrame
                )
                fullscreenWindows.append(info)
            }
        }
        
        return fullscreenWindows
    }
    
    // MARK: - Helper Functions

    /// Checks if a window's frame size matches a screen's frame size within tolerance.
    private func doesSizeMatchScreen(windowFrame: CGRect, screenFrame: CGRect) -> Bool {
        let widthTolerance = screenFrame.width * configuration.sizeTolerance
        let heightTolerance = screenFrame.height * configuration.sizeTolerance

        let widthMatch = abs(windowFrame.width - screenFrame.width) < widthTolerance
        let heightMatch = abs(windowFrame.height - screenFrame.height) < heightTolerance

        return widthMatch && heightMatch
    }

    /// Checks if a window's origin matches a screen's origin within tolerance.
    private func doesOriginMatchScreen(windowFrame: CGRect, screenFrame: CGRect) -> Bool {
        // Use the configured point tolerance
        let tolerance = configuration.originTolerance

        let originMatchX = abs(windowFrame.origin.x - screenFrame.origin.x) < tolerance
        let originMatchY = abs(windowFrame.origin.y - screenFrame.origin.y) < tolerance

        return originMatchX && originMatchY
    }
}

// Helper extension to safely create CGRect from the dictionary format used by CGWindowListCopyWindowInfo
extension CGRect {
    init?(dictionaryRepresentation dict: CFDictionary) {
        guard let dict = dict as? [String: CGFloat],
              let x = dict["X"],
              let y = dict["Y"],
              let width = dict["Width"],
              let height = dict["Height"] else {
            return nil // Failed to extract necessary keys
        }
        // Ensure width and height are non-negative, as required by CGRect
        guard width >= 0, height >= 0 else {
             // Invalid dimensions, treat as nil or handle as needed
             // For simplicity here, we return nil if dimensions are negative.
             // In practice, CGWindowList should provide non-negative dimensions.
             return nil
        }
        self.init(x: x, y: y, width: width, height: height)
    }
}
