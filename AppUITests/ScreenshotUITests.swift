import XCTest

/// Captures every screen in light mode, dark mode and at a large accessibility text size. Skipped unless a destination
/// folder is given:
/// `TEST_RUNNER_SCREENSHOT_DIR=/some/folder xcodebuild test ... -only-testing:FavorlyUITests/ScreenshotUITests`
final class ScreenshotUITests: UITestCase {
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

    /// Walks the demo script and writes `<screen>-<suffix>.png` for the five screens and the Nearby empty and error
    /// states.
    @MainActor
    private func captureScreens(
        appearance: XCUIDevice.Appearance,
        suffix: String,
        extraArguments: [String] = []
    ) throws {
        guard let folder = ProcessInfo.processInfo.environment["SCREENSHOT_DIR"] else {
            throw XCTSkip("Set TEST_RUNNER_SCREENSHOT_DIR to capture screenshots.")
        }
        XCUIDevice.shared.appearance = appearance
        app.launchArguments = ["-uiTesting"] + extraArguments
        app.launch()

        waitFor(element("nearby.count"), toRead: "7 requests")
        try capture("nearby-\(suffix)", into: folder)

        openTab("Post")
        app.textFields["post.title"].tap()
        app.typeText("Need a cup of rice\n")
        app.buttons["post.category"].tap()
        app.buttons["Ingredient"].tap()
        try capture("post-\(suffix)", into: folder)
        scrollToAndTap(app.buttons["post.submit"])
        XCTAssertTrue(row("activity.row.", containing: "Need a cup of rice")
            .waitForExistence(timeout: Self.waitTimeout))

        switchUser(to: "user-bea")
        try capture("dev-settings-\(suffix)", into: folder)
        openTab("Nearby")
        XCTAssertTrue(row("nearby.row.", containing: "yours").waitForExistence(timeout: Self.waitTimeout))
        try capture("nearby-yours-\(suffix)", into: folder)
        row("nearby.row.", containing: "Need a cup of rice").tap()
        waitFor(element("detail.title"), toRead: "Need a cup of rice")
        try capture("request-detail-open-\(suffix)", into: folder)
        scrollToAndTap(app.buttons["detail.pickUp"])
        app.buttons["Confirm pick up"].tap()
        XCTAssertTrue(app.buttons["detail.complete"].waitForExistence(timeout: Self.waitTimeout))
        try capture("request-detail-\(suffix)", into: folder)

        switchUser(to: "user-alex")
        openTab("Nearby")
        XCTAssertTrue(app.navigationBars["Request"].waitForExistence(timeout: Self.waitTimeout))
        try capture("request-detail-own-\(suffix)", into: folder)
        openTab("My Activity")
        XCTAssertTrue(row("activity.row.", containing: "Claimed by Bea").waitForExistence(timeout: Self.waitTimeout))
        try capture("my-activity-\(suffix)", into: folder)

        openTab("Dev Settings")
        scrollToAndTap(app.buttons["devSettings.location.ithaca"])
        openTab("Nearby")
        app.navigationBars.buttons.firstMatch.tap()
        waitFor(element("nearby.empty"), toRead: "No requests within 1 mi")
        try capture("nearby-empty-\(suffix)", into: folder)

        openTab("Dev Settings")
        scrollToAndTap(app.switches["devSettings.simulateLocationError"].switches.firstMatch)
        openTab("Nearby")
        waitFor(element("nearby.error"), toRead: "Your location isn't available right now.")
        try capture("nearby-error-\(suffix)", into: folder)
    }

    @MainActor
    private func capture(_ name: String, into folder: String) throws {
        let file = URL(fileURLWithPath: folder).appendingPathComponent("\(name).png")
        try XCUIScreen.main.screenshot().pngRepresentation.write(to: file)
    }
}
