import Foundation

// MARK: - Diagnostic Extensions

public extension MacroVisionKit.FullscreenWindowInfo {
    /// Generates a detailed diagnostic description
    var debugDescription: String {
        "📊 Analysis Result | Process: \(name ?? "Unknown") | ⚙️ PID: \(processId) | 📦 Bundle: \(bundleIdentifier ?? "No Bundle")"
    }
}
