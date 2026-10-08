import XCTest

/// Captures the README screenshots. Skipped unless a destination folder is given:
/// `TEST_RUNNER_SCREENSHOT_DIR=/some/folder xcodebuild test ... -only-testing:FavorlyUITests/ScreenshotUITests`
final class ScreenshotUITests: UITestCase {
    @MainActor
    func testCaptureScreenshots() throws {
        guard let folder = ProcessInfo.processInfo.environment["SCREENSHOT_DIR"] else {
            throw XCTSkip("Set TEST_RUNNER_SCREENSHOT_DIR to capture screenshots.")
        }
        launchApp()

        waitFor(element("nearby.count"), toRead: "7 requests")
        try capture("nearby", into: folder)

        openTab("Post")
        app.textFields["post.title"].tap()
        app.typeText("Need a cup of rice\n")
        app.buttons["post.category"].tap()
        app.buttons["Ingredient"].tap()
        try capture("post", into: folder)
        scrollToAndTap(app.buttons["post.submit"])
        XCTAssertTrue(row("activity.row.", containing: "Need a cup of rice")
            .waitForExistence(timeout: Self.waitTimeout))

        switchUser(to: "user-bea")
        try capture("dev-settings", into: folder)
        openTab("Nearby")
        row("nearby.row.", containing: "Need a cup of rice").tap()
        scrollToAndTap(app.buttons["detail.pickUp"])
        app.buttons["Confirm pick up"].tap()
        XCTAssertTrue(app.buttons["detail.complete"].waitForExistence(timeout: Self.waitTimeout))
        try capture("request-detail", into: folder)

        switchUser(to: "user-alex")
        openTab("My Activity")
        XCTAssertTrue(row("activity.row.", containing: "Claimed by Bea").waitForExistence(timeout: Self.waitTimeout))
        try capture("my-activity", into: folder)
    }

    @MainActor
    private func capture(_ name: String, into folder: String) throws {
        let file = URL(fileURLWithPath: folder).appendingPathComponent("\(name).png")
        try XCUIScreen.main.screenshot().pngRepresentation.write(to: file)
    }
}
