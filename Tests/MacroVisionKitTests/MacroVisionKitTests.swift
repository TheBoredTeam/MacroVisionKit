import XCTest
import AppKit
@testable import MacroVisionKit

final class MacroVisionKitTests: XCTestCase {
    
    var detector: MacroVisionKit!
    
    override func setUp() {
        super.setUp()
        detector = MacroVisionKit.shared
        detector.configuration = MacroVisionKit.Configuration()
        print("📝 [Line 13] Setup completed - Reset shared detector instance in MacroVisionKitTests.swift:setUp()")
    }
    
    override func tearDown() {
        detector = nil
        super.tearDown()
    }
    
    // MARK: - Configuration Tests
    
    func testDefaultConfiguration() {
        print("🔍 [Line 20] Testing default configuration in MacroVisionKitTests.swift:testDefaultConfiguration()")
        XCTAssertEqual(detector.configuration.sizeTolerance, 0.1, "Default size tolerance should be 0.1 (10%)")
        XCTAssertFalse(detector.configuration.includeSystemApps, "System apps should be excluded by default")
    }
    
    func testCustomConfiguration() {
        print("🔧 [Line 26] Testing custom configuration in MacroVisionKitTests.swift:testCustomConfiguration()")
        var config = MacroVisionKit.Configuration()
        config.sizeTolerance = 0.15
        config.includeSystemApps = true
        
        detector.configuration = config
        
        XCTAssertEqual(detector.configuration.sizeTolerance, 0.15, "Size tolerance should be updateable")
        XCTAssertTrue(detector.configuration.includeSystemApps, "System apps inclusion should be configurable")
    }
    
    // MARK: - Window Detection Tests
    
    func testDetectFullscreenApps() {
        let apps = detector.detectFullscreenApps()
        XCTAssertNotNil(apps, "Should return an array, even if empty")
    }
    
    func testDetectFullscreenAppsWithDebug() {
        let apps = detector.detectFullscreenApps(debug: true)
        XCTAssertNotNil(apps, "Should return results with debug mode enabled")
    }
    
    // MARK: - App Info Tests
    
    func testFullscreenAppInfo() {
        let currentApp = NSRunningApplication.current
        let screen = NSScreen.main
        let windowSize = CGSize(width: 1920, height: 1080)
        
        let appInfo = MacroVisionKit.FullscreenAppInfo(
            application: currentApp,
            screen: screen,
            windowSize: windowSize
        )
        
        // Test properties
        XCTAssertEqual(appInfo.application, currentApp, "Application reference should match")
        XCTAssertEqual(appInfo.screen, screen, "Screen reference should match")
        XCTAssertEqual(appInfo.windowSize, windowSize, "Window size should match")
        XCTAssertEqual(appInfo.processId, currentApp.processIdentifier, "Process ID should match")
        XCTAssertEqual(appInfo.bundleIdentifier, currentApp.bundleIdentifier, "Bundle ID should match")
        XCTAssertEqual(appInfo.name, currentApp.localizedName, "App name should match")
    }
    
    // MARK: - System App Filtering Tests
    
    func testSystemAppFiltering() {
        // Test with system apps excluded
        detector.configuration.includeSystemApps = false
        let appsWithoutSystem = detector.detectFullscreenApps()
        
        // Test with system apps included
        detector.configuration.includeSystemApps = true
        let appsWithSystem = detector.detectFullscreenApps()
        
        // Note: This test might need adjustment based on actual running apps
        XCTAssertNotNil(appsWithoutSystem, "Should return results with system apps excluded")
        XCTAssertNotNil(appsWithSystem, "Should return results with system apps included")
    }
    
    // MARK: - Size Tolerance Tests
    
    func testSizeToleranceCalculation() {
        let screen = NSScreen.main
        let screenSize = screen?.frame.size ?? .zero
        
        // Test with different tolerance values
        let tolerances: [CGFloat] = [0.05, 0.1, 0.15]
        
        tolerances.forEach { tolerance in
            detector.configuration.sizeTolerance = tolerance
            let apps = detector.detectFullscreenApps()
            XCTAssertNotNil(apps, "Should handle \(tolerance * 100)% tolerance")
        }
    }
    
    // MARK: - Debug Description Tests
    
    func testDebugDescription() {
        let currentApp = NSRunningApplication.current
        let appInfo = MacroVisionKit.FullscreenAppInfo(
            application: currentApp,
            screen: NSScreen.main,
            windowSize: CGSize(width: 1920, height: 1080)
        )
        
        let description = appInfo.debugDescription
        XCTAssertTrue(description.contains("Analysis Result"), "Description should contain analysis marker")
        XCTAssertTrue(description.contains("Process:"), "Description should contain process info")
        XCTAssertTrue(description.contains("PID:"), "Description should contain PID")
        XCTAssertTrue(description.contains("Bundle:"), "Description should contain bundle info")
    }
}

// MARK: - Performance Tests

extension MacroVisionKitTests {
    
    func testDetectionPerformance() {
        measure {
            _ = detector.detectFullscreenApps()
        }
    }
    
    func testDetectionWithDebugPerformance() {
        measure {
            _ = detector.detectFullscreenApps(debug: true)
        }
    }
} 
