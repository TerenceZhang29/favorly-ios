import XCTest

final class DevSettingsUITests: UITestCase {
    @MainActor
    func testSwitchingUserAndLocationUpdatesTheNearbyDebugLine() {
        launchApp()

        let debugLine = element("nearby.debugSummary")
        waitFor(debugLine, toRead: "Alex @ Cornell Tech, Roosevelt Island")

        openTab("Dev Settings")
        waitFor(element("devSettings.summary"), toRead: "Alex @ Cornell Tech, Roosevelt Island")
        app.buttons["devSettings.user.user-bea"].tap()
        waitFor(element("devSettings.summary"), toRead: "Bea @ Cornell Tech, Roosevelt Island")
        // Tapping the last preset scrolls the summary row off screen, so the result is checked on Nearby.
        app.buttons["devSettings.location.ithaca"].tap()

        openTab("Nearby")
        waitFor(debugLine, toRead: "Bea @ Ithaca, NY")
    }
}
