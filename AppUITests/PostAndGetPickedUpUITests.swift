import XCTest

/// Flow 1 from the plan: Alex posts a request, Bea picks it up, Alex sees who claimed it.
final class PostAndGetPickedUpUITests: XCTestCase {
    @MainActor private lazy var app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testAlexPostsBeaPicksUpAndAlexSeesTheClaim() {
        app.launch()

        // Alex posts.
        app.tabBars.buttons["Post"].tap()
        waitFor(app.staticTexts["post.location"], toRead: "Tagged at Cornell Tech, Roosevelt Island")
        XCTAssertFalse(app.buttons["post.submit"].isEnabled)

        app.textFields["post.title"].tap()
        app.typeText("ab")
        waitFor(app.staticTexts["post.titleMessage"], toRead: "Title must be at least 3 characters.")
        XCTAssertFalse(app.buttons["post.submit"].isEnabled)
        app.typeText("\u{8}\u{8}Need a cup of rice\n")

        app.buttons["post.category"].tap()
        app.buttons["Ingredient"].tap()
        app.buttons["post.submit"].tap()

        // The app moves to My Activity and shows the new request as open.
        let alexRow = row("activity.row.", containing: "Need a cup of rice")
        XCTAssertTrue(alexRow.waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["My Activity"].isSelected)
        XCTAssertTrue(alexRow.label.contains("Open"))
        XCTAssertTrue(alexRow.label.contains("New"))

        // Bea finds it at the top of Nearby and picks it up.
        switchUser(to: "user-bea")
        app.tabBars.buttons["Nearby"].tap()
        waitFor(app.staticTexts["nearby.count"], toRead: "8 requests")
        let nearbyRow = row("nearby.row.", containing: "Need a cup of rice")
        XCTAssertTrue(nearbyRow.label.contains("< 0.1 mi"))
        XCTAssertTrue(nearbyRow.label.contains("Alex"))
        nearbyRow.tap()

        app.buttons["detail.pickUp"].tap()
        app.buttons["Confirm pick up"].tap()
        waitFor(app.staticTexts["detail.status"], toRead: "Claimed by Bea")

        app.tabBars.buttons["My Activity"].tap()
        app.segmentedControls["activity.segment"].buttons["Picked up by me"].tap()
        let beaRow = row("activity.row.", containing: "Need a cup of rice")
        XCTAssertTrue(beaRow.waitForExistence(timeout: 5))
        XCTAssertTrue(beaRow.label.contains("Posted by Alex"))

        // Alex sees who claimed it and marks it completed.
        switchUser(to: "user-alex")
        app.tabBars.buttons["My Activity"].tap()
        app.segmentedControls["activity.segment"].buttons["My requests"].tap()
        let claimedRow = row("activity.row.", containing: "Claimed by Bea")
        XCTAssertTrue(claimedRow.waitForExistence(timeout: 5))
        XCTAssertTrue(claimedRow.label.contains("Need a cup of rice"))
        claimedRow.tap()

        waitFor(app.staticTexts["detail.status"], toRead: "Claimed by Bea")
        app.buttons["detail.complete"].tap()
        waitFor(app.staticTexts["detail.status"], toRead: "Completed")
    }

    @MainActor
    func testMyActivityIsEmptyForAlexAtLaunch() {
        app.launch()
        app.tabBars.buttons["My Activity"].tap()
        waitFor(app.staticTexts["activity.empty"], toRead: "You haven't posted any requests yet.")
        app.segmentedControls["activity.segment"].buttons["Picked up by me"].tap()
        waitFor(app.staticTexts["activity.empty"], toRead: "You haven't picked up any requests yet.")
    }

    @MainActor
    private func switchUser(to id: String) {
        app.tabBars.buttons["Dev Settings"].tap()
        app.buttons["devSettings.user.\(id)"].tap()
    }

    @MainActor
    private func row(_ prefix: String, containing text: String) -> XCUIElement {
        let matches = NSPredicate(format: "identifier BEGINSWITH %@ AND label CONTAINS %@", prefix, text)
        return app.buttons.matching(matches).firstMatch
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
