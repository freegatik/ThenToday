import XCTest

final class ThenTodayUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-UITesting")
        app.launch()
    }

    func testPickDateOpenDetailAndBack() {
        let datePicker = app.datePickers.matching(identifier: "datePicker").firstMatch
        XCTAssertTrue(datePicker.waitForExistence(timeout: 10))
        app.buttons["findOutButton"].tap()

        let fact = app.staticTexts["factLabel"].firstMatch
        XCTAssertTrue(fact.waitForExistence(timeout: 10))
        XCTAssertTrue(fact.label.contains("UI test"))

        let back = app.buttons["navBackButton"]
        XCTAssertTrue(back.waitForExistence(timeout: 5))
        back.tap()

        XCTAssertTrue(datePicker.waitForExistence(timeout: 8))
    }

    func testLanguagePickerRetranslates() {
        let datePicker = app.datePickers.matching(identifier: "datePicker").firstMatch
        XCTAssertTrue(datePicker.waitForExistence(timeout: 10))
        app.buttons["findOutButton"].tap()

        XCTAssertTrue(app.staticTexts["factLabel"].waitForExistence(timeout: 10))

        let wheel = app.pickers["languagePicker"].pickerWheels.firstMatch
        XCTAssertTrue(wheel.waitForExistence(timeout: 10))
        wheel.adjust(toPickerWheelValue: "English")

        let fact = app.staticTexts["factLabel"].firstMatch
        XCTAssertTrue(fact.waitForExistence(timeout: 20))
        XCTAssertTrue(fact.label.contains("[en]"), "unexpected label: \(fact.label)")
    }

    func testExplorationFailureShowsAlert() {
        app.terminate()
        app = XCUIApplication()
        app.launchArguments = ["-UITesting", "-UITestingNetworkError"]
        app.launch()

        let datePicker = app.datePickers.matching(identifier: "datePicker").firstMatch
        XCTAssertTrue(datePicker.waitForExistence(timeout: 10))
        app.buttons["findOutButton"].tap()

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 10))
        alert.buttons.firstMatch.tap()
        XCTAssertTrue(datePicker.waitForExistence(timeout: 8))
    }
}
