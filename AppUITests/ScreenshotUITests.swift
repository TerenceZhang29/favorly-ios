import XCTest

/// Captures every screen in light mode, dark mode and at a large accessibility text size. Skipped unless a destination
/// folder is given:
/// `TEST_RUNNER_SCREENSHOT_DIR=/some/folder xcodebuild test ... -only-testing:FavorlyUITests/ScreenshotUITests`
final class ScreenshotUITests: UITestCase {
    @MainActor private var folder = ""
    @MainActor private var suffix = ""

    override func tearDown() {
        MainActor.assumeIsolated {
            XCUIDevice.shared.appearance = .light
        }
        super.tearDown()
    }

    @MainActor
    func testCaptureScreenshotsInLightMode() throws {
        try captureScreens(appearance: .light, suffix: "light")
    }

    @MainActor
    func testCaptureScreenshotsInDarkMode() throws {
        try captureScreens(appearance: .dark, suffix: "dark")
    }

    @MainActor
    func testCaptureScreenshotsAtAccessibilityLargeText() throws {
        try captureScreens(
            appearance: .light,
            suffix: "accessibility-large",
            extraArguments: ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityL"]
        )
    }

    /// Walks the demo script and writes `<screen>-<suffix>.png` for the five screens and their main states.
    @MainActor
    private func captureScreens(
        appearance: XCUIDevice.Appearance,
        suffix: String,
        extraArguments: [String] = []
    ) throws {
        guard let folder = ProcessInfo.processInfo.environment["SCREENSHOT_DIR"] else {
            throw XCTSkip("Set TEST_RUNNER_SCREENSHOT_DIR to capture screenshots.")
        }
        self.folder = folder
        self.suffix = suffix
        XCUIDevice.shared.appearance = appearance
        app.launchArguments = ["-uiTesting"] + extraArguments
        app.launch()

        try alexPostsARequest()
        try beaPicksItUp()
        try alexSeesItClaimed()
        try farAwayAndLocationError()
    }

    @MainActor
    private func alexPostsARequest() throws {
        waitFor(element("nearby.count"), toRead: "7 requests")
        try capture("nearby")

        openTab("My Activity")
        waitFor(element("activity.empty"), toRead: "You haven't posted any requests yet.")
        try capture("my-activity-empty")

        openTab("Post")
        waitFor(element("post.location"), toRead: "Tagged at Cornell Tech, Roosevelt Island")
        try capture("post-empty")
        app.textFields["post.title"].tap()
        app.typeText("Ne")
        waitFor(element("post.titleMessage"), toRead: "Title must be at least 3 characters.")
        try capture("post-invalid")
        app.typeText("ed a cup of rice\n")
        app.buttons["post.category"].tap()
        app.buttons["Ingredient"].tap()
        try capture("post")
        scrollToAndTap(app.buttons["post.submit"])
        XCTAssertTrue(row("activity.row.", containing: "Need a cup of rice")
            .waitForExistence(timeout: Self.waitTimeout))
        try capture("my-activity-new")
    }

    @MainActor
    private func beaPicksItUp() throws {
        switchUser(to: "user-bea")
        try capture("dev-settings")
        openTab("Nearby")
        XCTAssertTrue(row("nearby.row.", containing: "yours").waitForExistence(timeout: Self.waitTimeout))
        try capture("nearby-yours")
        row("nearby.row.", containing: "Need a cup of rice").tap()
        waitFor(element("detail.title"), toRead: "Need a cup of rice")
        try capture("request-detail-open")
        scrollToAndTap(app.buttons["detail.pickUp"])
        app.buttons["Confirm pick up"].tap()
        XCTAssertTrue(app.buttons["detail.complete"].waitForExistence(timeout: Self.waitTimeout))
        try capture("request-detail")

        openTab("My Activity")
        app.segmentedControls["activity.segment"].buttons["Picked up by me"].tap()
        XCTAssertTrue(row("activity.row.", containing: "Posted by Alex").waitForExistence(timeout: Self.waitTimeout))
        try capture("my-activity-picked-up")
        app.segmentedControls["activity.segment"].buttons["My requests"].tap()
    }

    @MainActor
    private func alexSeesItClaimed() throws {
        switchUser(to: "user-alex")
        openTab("Nearby")
        // Wait for something at the top: at large text sizes the buttons below the fold do not exist yet.
        XCTAssertTrue(app.navigationBars["Request"].waitForExistence(timeout: Self.waitTimeout))
        try capture("request-detail-own")
        openTab("My Activity")
        XCTAssertTrue(row("activity.row.", containing: "Claimed by Bea").waitForExistence(timeout: Self.waitTimeout))
        try capture("my-activity")
    }

    @MainActor
    private func farAwayAndLocationError() throws {
        openTab("Dev Settings")
        scrollToAndTap(app.buttons["devSettings.location.ithaca"])
        openTab("Nearby")
        app.navigationBars.buttons.firstMatch.tap()
        waitFor(element("nearby.empty"), toRead: "No requests within 1 mi")
        try capture("nearby-empty")

        openTab("Dev Settings")
        scrollToAndTap(app.switches["devSettings.simulateLocationError"].switches.firstMatch)
        openTab("Nearby")
        waitFor(element("nearby.error"), toRead: "Your location isn't available right now.")
        try capture("nearby-error")

        openTab("Dev Settings")
        app.swipeUp()
        try capture("dev-settings-bottom")
    }

    @MainActor
    private func capture(_ name: String) throws {
        let file = URL(fileURLWithPath: folder).appendingPathComponent("\(name)-\(suffix).png")
        try XCUIScreen.main.screenshot().pngRepresentation.write(to: file)
    }
}
