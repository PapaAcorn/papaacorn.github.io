import XCTest

final class TemperatureTrainerUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchShowsTemperatureTrainerSurface() throws {
        let app = XCUIApplication()
        app.launch()

        let brand = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Metric Sense")).firstMatch
        XCTAssertTrue(brand.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Temperature Trainer"].exists)
        XCTAssertTrue(app.staticTexts["ROUND"].exists)
        XCTAssertTrue(app.staticTexts["LEARNED HERE"].exists)
        XCTAssertTrue(app.staticTexts["TOTAL LEARNED"].exists)
        XCTAssertTrue(app.buttons["Reset practice progress"].exists)
    }

    func testAnsweringCurrentPromptShowsFeedbackAndContinueAction() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Temperature Trainer"].waitForExistence(timeout: 5))

        if app.buttons["Lock in estimate"].exists {
            app.buttons["Lock in estimate"].tap()
        } else {
            let celsiusChoice = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] '°C'")).firstMatch
            XCTAssertTrue(celsiusChoice.waitForExistence(timeout: 2))
            celsiusChoice.tap()
        }

        let correctFeedback = app.staticTexts["Nice instinct."]
        let reviewFeedback = app.staticTexts["We'll show this again."]
        XCTAssertTrue(
            correctFeedback.waitForExistence(timeout: 2) || reviewFeedback.waitForExistence(timeout: 2)
        )
        XCTAssertTrue(app.buttons["Continue"].exists)
    }

    func testResetProgressButtonRemainsAvailableAfterScroll() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Temperature Trainer"].waitForExistence(timeout: 5))
        app.swipeUp()

        XCTAssertTrue(app.buttons["Reset practice progress"].waitForExistence(timeout: 2))
    }
}
