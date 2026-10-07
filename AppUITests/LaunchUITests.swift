import XCTest

final class LaunchUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchShowsFourTabs() {
        let app = XCUIApplication()
        app.launch()

        for title in ["Nearby", "Post", "My Activity", "Dev Settings"] {
            XCTAssertTrue(app.tabBars.buttons[title].waitForExistence(timeout: 5), "Missing tab: \(title)")
        }
    }
}
