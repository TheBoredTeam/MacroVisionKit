import XCTest
import AppKit
@testable import MacroVisionKit

final class MacroVisionKitTests: XCTestCase {
    var detector: MacroVisionKit!

    override func setUp() {
        super.setUp()
        detector = MacroVisionKit.shared
        detector.configuration = .init() // reset to defaults
    }
    
    override func tearDown() {
        detector = nil
        super.tearDown()
    }

    // MARK: – Configuration Tests

    func testDefaultConfiguration() {
        XCTAssertEqual(detector.configuration.sizeTolerance, 0.02, accuracy: 1e-4)
        XCTAssertEqual(detector.configuration.originTolerance, 5.0, accuracy: 1e-4)
        XCTAssertFalse(detector.configuration.includeSystemApps)
    }

    func testCustomConfiguration() {
        let custom = MacroVisionKit.Configuration(sizeTolerance: 0.15,
                                                  originTolerance: 10.0,
                                                  includeSystemApps: true)
        detector.configuration = custom
        XCTAssertEqual(detector.configuration.sizeTolerance, 0.15)
        XCTAssertEqual(detector.configuration.originTolerance, 10.0)
        XCTAssertTrue(detector.configuration.includeSystemApps)
    }
}

// MARK: – FullscreenWindowInfo Tests

extension MacroVisionKitTests {
    func testFullscreenWindowInfoComputedProperties() {
        let app = NSRunningApplication.current
        guard let screen = NSScreen.main else {
            return XCTFail("No NSScreen available")
        }
        let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let info = MacroVisionKit.FullscreenWindowInfo(application: app,
                                                       screen: screen,
                                                       windowFrame: frame)

        XCTAssertEqual(info.application, app)
        XCTAssertEqual(info.screen, screen)
        XCTAssertEqual(info.windowFrame, frame)
        XCTAssertEqual(info.bundleIdentifier, app.bundleIdentifier)
        XCTAssertEqual(info.name, app.localizedName)
        XCTAssertEqual(info.processId, app.processIdentifier)
    }

    func testDetectFullscreenAppsReturnsArray() {
        let result = detector.detectFullscreenApps()
        XCTAssertNotNil(result)
        XCTAssertTrue(result is [MacroVisionKit.FullscreenWindowInfo])
    }
}
