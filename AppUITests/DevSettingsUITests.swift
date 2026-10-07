import XCTest

final class DevSettingsUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testSwitchingUserAndLocationUpdatesTheNearbyDebugLine() {
        let app = XCUIApplication()
        app.launch()

        let debugLine = app.staticTexts["nearby.debugSummary"]
        XCTAssertTrue(debugLine.waitForExistence(timeout: 5))
        XCTAssertEqual(debugLine.label, "Alex @ Cornell Tech, Roosevelt Island")

        app.tabBars.buttons["Dev Settings"].tap()
        XCTAssertEqual(app.staticTexts["devSettings.summary"].label, "Alex @ Cornell Tech, Roosevelt Island")
        app.buttons["devSettings.user.user-bea"].tap()
        XCTAssertEqual(app.staticTexts["devSettings.summary"].label, "Bea @ Cornell Tech, Roosevelt Island")
        // Tapping the last preset scrolls the summary row off screen, so the result is checked on Nearby.
        app.buttons["devSettings.location.ithaca"].tap()

        app.tabBars.buttons["Nearby"].tap()
        XCTAssertEqual(debugLine.label, "Bea @ Ithaca, NY")
    }
}
