import XCTest

/// Shared launch and lookup helpers. Each test launches the app fresh with no mock delay.
class UITestCase: XCTestCase {
    @MainActor lazy var app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func launchApp() {
        app.launchArguments = ["-uiTesting"]
        app.launch()
    }

    /// Finds an element by accessibility identifier, whatever kind of element it is.
    @MainActor
    func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier].firstMatch
    }

    /// Finds a list row by identifier prefix and part of its spoken label.
    @MainActor
    func row(_ prefix: String, containing text: String) -> XCUIElement {
        let matches = NSPredicate(format: "identifier BEGINSWITH %@ AND label CONTAINS %@", prefix, text)
        return app.buttons.matching(matches).firstMatch
    }

    @MainActor
    func openTab(_ title: String) {
        app.tabBars.buttons[title].tap()
    }

    @MainActor
    func switchUser(to id: String) {
        openTab("Dev Settings")
        app.buttons["devSettings.user.\(id)"].tap()
    }

    /// Scrolls up until the element is on screen, for lists that grow at large text sizes, then taps it.
    @MainActor
    func scrollToAndTap(_ element: XCUIElement) {
        for _ in 0 ..< 4 where !(element.exists && element.isHittable) {
            app.swipeUp()
        }
        element.tap()
    }

    /// Waits until the element's label or value is `text`.
    @MainActor
    func waitFor(_ element: XCUIElement, toRead text: String, file: StaticString = #filePath, line: UInt = #line) {
        let matches = NSPredicate(format: "exists == true AND (label == %@ OR value == %@)", text, text)
        let expectation = XCTNSPredicateExpectation(predicate: matches, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        let found = element.exists ? "\(element.label) / \(String(describing: element.value))" : "nothing"
        XCTAssertEqual(result, .completed, "Expected \"\(text)\", found \(found)", file: file, line: line)
    }
}
