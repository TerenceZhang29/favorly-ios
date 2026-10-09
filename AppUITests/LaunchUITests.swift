import XCTest

final class LaunchUITests: UITestCase {
    @MainActor
    func testLaunchShowsFiveTabs() {
        launchApp()

        for title in ["Nearby", "Post", "My Activity", "Profile", "Dev Settings"] {
            XCTAssertTrue(
                app.tabBars.buttons[title].waitForExistence(timeout: Self.waitTimeout),
                "Missing tab: \(title)"
            )
        }
    }

    @MainActor
    func testLaunchWithoutTheTestingFlagStillLoadsNearby() {
        app.launch()
        waitFor(element("nearby.count"), toRead: "7 requests")
    }
}
