import XCTest

/// Flow 2 from the plan: browse nearby, change the radius, open a request and pick it up.
final class BrowseAndPickUpUITests: XCTestCase {
    private let eggsRow = "nearby.row.00000000-0000-0000-0000-000000000001"
    private let riceRow = "nearby.row.00000000-0000-0000-0000-000000000002"

    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testBeaBrowsesNearbyAndPicksUpARequest() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Dev Settings"].tap()
        app.buttons["devSettings.user.user-bea"].tap()
        app.tabBars.buttons["Nearby"].tap()

        let count = app.staticTexts["nearby.count"]
        waitFor(count, toRead: "7 requests")
        XCTAssertTrue(app.buttons[riceRow].label.contains("Yours"))
        XCTAssertFalse(app.buttons[eggsRow].label.contains("Yours"))

        let radius = app.segmentedControls["nearby.radiusPicker"]
        radius.buttons["0.25 mi"].tap()
        waitFor(count, toRead: "3 requests")
        radius.buttons["3 mi"].tap()
        waitFor(count, toRead: "8 requests")

        app.buttons[eggsRow].tap()
        XCTAssertTrue(app.staticTexts["detail.title"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["detail.title"].label, "Need 2 eggs for a cake")
        XCTAssertEqual(app.staticTexts["detail.status"].label, "Open")

        app.buttons["detail.pickUp"].tap()
        app.buttons["Confirm pick up"].tap()
        waitFor(app.staticTexts["detail.status"], toRead: "Claimed by Bea")
        XCTAssertFalse(app.buttons["detail.pickUp"].exists)

        app.navigationBars.buttons.firstMatch.tap()
        waitFor(count, toRead: "7 requests")
        XCTAssertFalse(app.buttons[eggsRow].exists)
    }

    @MainActor
    func testOwnRequestHasNoPickUpButton() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Dev Settings"].tap()
        app.buttons["devSettings.user.user-bea"].tap()
        app.tabBars.buttons["Nearby"].tap()

        XCTAssertTrue(app.buttons[riceRow].waitForExistence(timeout: 5))
        app.buttons[riceRow].tap()
        XCTAssertTrue(app.staticTexts["detail.title"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["detail.requester"].label, "Bea (you)")
        XCTAssertFalse(app.buttons["detail.pickUp"].exists)
        XCTAssertTrue(app.buttons["detail.cancel"].exists)
    }

    @MainActor
    func testFarAwayLocationShowsTheEmptyStateAndLocationErrorOffersRetry() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Dev Settings"].tap()
        app.buttons["devSettings.location.ithaca"].tap()
        app.tabBars.buttons["Nearby"].tap()
        waitFor(app.staticTexts["nearby.empty"], toRead: "No requests within 1 mi")

        app.tabBars.buttons["Dev Settings"].tap()
        app.switches["devSettings.simulateLocationError"].switches.firstMatch.tap()
        app.tabBars.buttons["Nearby"].tap()
        waitFor(app.staticTexts["nearby.error"], toRead: "Your location isn't available right now.")
        XCTAssertTrue(app.buttons["nearby.retry"].exists)
    }

    @MainActor
    private func waitFor(
        _ element: XCUIElement,
        toRead text: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let matches = NSPredicate(format: "exists == true AND label == %@", text)
        let expectation = XCTNSPredicateExpectation(predicate: matches, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(
            result, .completed,
            "Expected \"\(text)\", found \"\(element.exists ? element.label : "nothing")\"",
            file: file, line: line
        )
    }
}
