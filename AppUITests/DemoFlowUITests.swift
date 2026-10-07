import XCTest

/// The demo script in docs/PLAN.md, which is Flow 1 end to end: Alex posts, Bea picks up, Alex sees the claim.
final class DemoFlowUITests: UITestCase {
    @MainActor private var count: XCUIElement { element("nearby.count") }

    @MainActor
    func testDemoScript() {
        launchApp()
        browseNearbyAsAlex()
        postARequestAsAlex()
        pickItUpAsBea()
        completeItAsAlex()
        moveFarAwayAndReset()
    }

    /// Steps 1 and 2: Dev Settings shows who is signed in, and the radius changes the Nearby list.
    @MainActor
    private func browseNearbyAsAlex() {
        openTab("Dev Settings")
        waitFor(element("devSettings.summary"), toRead: "Alex @ Cornell Tech, Roosevelt Island")

        openTab("Nearby")
        let radius = app.segmentedControls["nearby.radiusPicker"]
        waitFor(count, toRead: "7 requests")
        radius.buttons["0.25 mi"].tap()
        waitFor(count, toRead: "3 requests")
        radius.buttons["3 mi"].tap()
        waitFor(count, toRead: "8 requests")
        radius.buttons["1 mi"].tap()
        waitFor(count, toRead: "7 requests")
    }

    /// Step 3: Alex posts, and My Activity shows the request as open.
    @MainActor
    private func postARequestAsAlex() {
        openTab("Post")
        waitFor(element("post.location"), toRead: "Tagged at Cornell Tech, Roosevelt Island")
        XCTAssertFalse(app.buttons["post.submit"].isEnabled)
        app.textFields["post.title"].tap()
        app.typeText("ab")
        waitFor(element("post.titleMessage"), toRead: "Title must be at least 3 characters.")
        XCTAssertFalse(app.buttons["post.submit"].isEnabled)
        app.typeText("\u{8}\u{8}Need a cup of rice\n")
        app.buttons["post.category"].tap()
        app.buttons["Ingredient"].tap()
        app.buttons["post.submit"].tap()

        let postedRow = row("activity.row.", containing: "Need a cup of rice")
        XCTAssertTrue(postedRow.waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["My Activity"].isSelected)
        XCTAssertEqual(postedRow.label, "Need a cup of rice, Ingredient, Open, new")
    }

    /// Steps 4 and 5: Bea sees the request at the top of Nearby and picks it up.
    /// It leaves Nearby and appears under Picked up by me.
    @MainActor
    private func pickItUpAsBea() {
        switchUser(to: "user-bea")
        openTab("Nearby")
        waitFor(count, toRead: "8 requests")
        let nearbyRow = row("nearby.row.", containing: "Need a cup of rice")
        XCTAssertTrue(nearbyRow.label.contains("less than 0.1 miles away"))
        XCTAssertTrue(nearbyRow.label.hasSuffix("by Alex"))

        nearbyRow.tap()
        app.buttons["detail.pickUp"].tap()
        app.buttons["Confirm pick up"].tap()
        waitFor(element("detail.status"), toRead: "Claimed by Bea")
        app.navigationBars.buttons.firstMatch.tap()
        waitFor(count, toRead: "7 requests")
        XCTAssertFalse(row("nearby.row.", containing: "Need a cup of rice").exists)

        openTab("My Activity")
        app.segmentedControls["activity.segment"].buttons["Picked up by me"].tap()
        let pickedUpRow = row("activity.row.", containing: "Need a cup of rice")
        XCTAssertTrue(pickedUpRow.waitForExistence(timeout: 5))
        XCTAssertTrue(pickedUpRow.label.hasSuffix("Claimed by Bea, Posted by Alex"))
    }

    /// Step 6: Alex sees who claimed it and marks it completed.
    @MainActor
    private func completeItAsAlex() {
        switchUser(to: "user-alex")
        openTab("My Activity")
        app.segmentedControls["activity.segment"].buttons["My requests"].tap()
        let claimedRow = row("activity.row.", containing: "Claimed by Bea")
        XCTAssertTrue(claimedRow.waitForExistence(timeout: 5))
        claimedRow.tap()
        waitFor(element("detail.status"), toRead: "Claimed by Bea")
        app.buttons["detail.complete"].tap()
        waitFor(element("detail.status"), toRead: "Completed")
        app.navigationBars.buttons.firstMatch.tap()
    }

    /// Step 7: from Ithaca nothing is nearby, and resetting clears what the demo created.
    @MainActor
    private func moveFarAwayAndReset() {
        openTab("Dev Settings")
        app.buttons["devSettings.location.ithaca"].tap()
        openTab("Nearby")
        waitFor(element("nearby.empty"), toRead: "No requests within 1 mi")

        openTab("Dev Settings")
        let reset = app.buttons["devSettings.resetDemoData"]
        if !reset.isHittable {
            app.swipeUp()
        }
        reset.tap()
        openTab("My Activity")
        waitFor(element("activity.empty"), toRead: "You haven't posted any requests yet.")
    }

    @MainActor
    func testMyActivityIsEmptyForAlexAtLaunch() {
        launchApp()
        openTab("My Activity")
        waitFor(element("activity.empty"), toRead: "You haven't posted any requests yet.")
        app.segmentedControls["activity.segment"].buttons["Picked up by me"].tap()
        waitFor(element("activity.empty"), toRead: "You haven't picked up any requests yet.")
    }
}
