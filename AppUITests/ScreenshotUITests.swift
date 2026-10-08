import XCTest

/// Captures every screen in light and dark mode. Skipped unless a destination folder is given:
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

    /// Walks the demo script and writes `<screen>-<suffix>.png` for the five screens and the Nearby empty state.
    @MainActor
    private func captureScreens(appearance: XCUIDevice.Appearance, suffix: String) throws {
        guard let folder = ProcessInfo.processInfo.environment["SCREENSHOT_DIR"] else {
            throw XCTSkip("Set TEST_RUNNER_SCREENSHOT_DIR to capture screenshots.")
        }
        XCUIDevice.shared.appearance = appearance
        launchApp()

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
        row("nearby.row.", containing: "Need a cup of rice").tap()
        scrollToAndTap(app.buttons["detail.pickUp"])
        app.buttons["Confirm pick up"].tap()
        XCTAssertTrue(app.buttons["detail.complete"].waitForExistence(timeout: Self.waitTimeout))
        try capture("request-detail-\(suffix)", into: folder)

        switchUser(to: "user-alex")
        openTab("My Activity")
        XCTAssertTrue(row("activity.row.", containing: "Claimed by Bea").waitForExistence(timeout: Self.waitTimeout))
        try capture("my-activity-\(suffix)", into: folder)

        openTab("Dev Settings")
        app.buttons["devSettings.location.ithaca"].tap()
        openTab("Nearby")
        app.navigationBars.buttons.firstMatch.tap()
        waitFor(element("nearby.empty"), toRead: "No requests within 1 mi")
        try capture("nearby-empty-\(suffix)", into: folder)
    }

    @MainActor
    private func capture(_ name: String, into folder: String) throws {
        let file = URL(fileURLWithPath: folder).appendingPathComponent("\(name).png")
        try XCUIScreen.main.screenshot().pngRepresentation.write(to: file)
    }
}
