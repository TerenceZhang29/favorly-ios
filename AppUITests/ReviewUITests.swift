import XCTest

/// Reviews (Phase 3D): the requester reviews the helper, and the review shows on the helper's profile.
final class ReviewUITests: UITestCase {
    @MainActor
    func testDanaReviewsBeaAndTheReviewShowsOnHerProfile() {
        launchApp()
        switchUser(to: "user-dana")
        openTab("My Activity")
        let saffron = row("activity.row.", containing: "Need a pinch of saffron")
        XCTAssertTrue(saffron.waitForExistence(timeout: Self.waitTimeout))
        saffron.tap()
        waitFor(element("detail.status"), toRead: "Completed")

        scrollToAndTap(app.buttons["detail.review"])
        let submit = app.buttons["review.submit"]
        XCTAssertTrue(submit.waitForExistence(timeout: Self.waitTimeout))
        XCTAssertFalse(submit.isEnabled)
        app.buttons["review.star.5"].tap()
        XCTAssertTrue(submit.isEnabled)
        element("review.comment").tap()
        app.typeText("Fast and friendly")
        waitFor(element("review.count"), toRead: "17 / 300")
        submit.tap()

        let summary = element("detail.reviewSummary")
        XCTAssertTrue(summary.waitForExistence(timeout: Self.waitTimeout))
        XCTAssertEqual(summary.label, "Your review")
        XCTAssertEqual(summary.value as? String, "5 out of 5 stars: Fast and friendly")
        XCTAssertFalse(app.buttons["detail.review"].exists)

        scrollToAndTap(element("detail.helper"))
        waitFor(element("profile.name"), toRead: "Bea")
        waitFor(element("profile.score"), toRead: "100 points")
        let review = app.descendants(matching: .any).matching(NSPredicate(
            format: "identifier BEGINSWITH %@ AND label CONTAINS %@", "profile.review.", "from Dana"
        )).firstMatch
        for _ in 0 ..< 6 where !(review.exists && review.isHittable) {
            app.swipeUp()
        }
        XCTAssertTrue(review.label.hasPrefix("5 out of 5 stars from Dana"))
        XCTAssertTrue(review.label.hasSuffix(": Fast and friendly"))
    }

    @MainActor
    func testCancelLeavesNoReview() {
        launchApp()
        switchUser(to: "user-dana")
        openTab("My Activity")
        let saffron = row("activity.row.", containing: "Need a pinch of saffron")
        XCTAssertTrue(saffron.waitForExistence(timeout: Self.waitTimeout))
        saffron.tap()
        scrollToAndTap(app.buttons["detail.review"])
        XCTAssertTrue(app.buttons["review.cancel"].waitForExistence(timeout: Self.waitTimeout))
        app.buttons["review.star.3"].tap()
        app.buttons["review.cancel"].tap()
        XCTAssertTrue(app.buttons["detail.review"].waitForExistence(timeout: Self.waitTimeout))
        XCTAssertFalse(element("detail.reviewSummary").exists)
    }
}
