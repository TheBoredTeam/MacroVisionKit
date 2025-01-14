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
        /// Default is 0.1 (10% tolerance)
        public var sizeTolerance: CGFloat = 0.1
        
        /// Process filtering configuration for system applications
        public var includeSystemApps: Bool = false
        
        public init(sizeTolerance: CGFloat = 0.1, includeSystemApps: Bool = false) {
            self.sizeTolerance = sizeTolerance
            self.includeSystemApps = includeSystemApps
        }
    }
    
    /// Active configuration parameters
    public var configuration: Configuration
    
    private init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }
    
    /// Comprehensive information about a detected fullscreen application
    public struct FullscreenAppInfo {
        /// The active application process
        public let application: NSRunningApplication
        /// Associated display device
        public let screen: NSScreen?
        /// Current viewport dimensions
        public let windowSize: CGSize
        
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
    public func detectFullscreenApps(debug: Bool = false) -> [FullscreenAppInfo] {
        let workspace = NSWorkspace.shared
        let apps = workspace.runningApplications
        
        if debug {
            print("🔬 Analyzing running processes:")
            apps.forEach { app in
                print("📊 Process: \(app.localizedName ?? "Unknown"), Bundle: \(app.bundleIdentifier ?? "No Bundle")")
            }
        }
        
        let fullscreenApps = apps.compactMap { app -> FullscreenAppInfo? in
            // Apply process filtering
            if !configuration.includeSystemApps,
               app.bundleIdentifier?.hasPrefix("com.apple.") ?? false {
                return nil
            }
            
            let screen = NSScreen.main
            let screenFrame = screen?.frame ?? .zero
            
            if debug {
                print("📺 Display metrics: \(screenFrame.width) x \(screenFrame.height)")
            }
            
            // Acquire window state information
            let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
            let appWindows = windowList.filter { windowInfo in
                (windowInfo[kCGWindowOwnerPID as String] as? pid_t) == app.processIdentifier
            }
            
            if debug {
                print("🪟 Viewport analysis for \(app.localizedName ?? "Unknown"):")
                appWindows.forEach { window in
                    if let bounds = window[kCGWindowBounds as String] as? [String: CGFloat] {
                        print("   Dimensions: \(bounds["Width"] ?? 0) x \(bounds["Height"] ?? 0)")
                    }
                }
            }
            
            // Analyze viewport utilization
            for windowInfo in appWindows {
                guard let bounds = windowInfo[kCGWindowBounds as String] as? [String: CGFloat],
                      let width = bounds["Width"],
                      let height = bounds["Height"] else {
                    continue
                }
                
                let widthMatch = abs(width - screenFrame.width) < screenFrame.width * configuration.sizeTolerance
                let heightMatch = abs(height - screenFrame.height) < screenFrame.height * configuration.sizeTolerance
                
                if widthMatch && heightMatch {
                    return FullscreenAppInfo(
                        application: app,
                        screen: screen,
                        windowSize: CGSize(width: width, height: height)
                    )
                }
            }
            
            return nil
        }
        
        return fullscreenApps
    }
}
