import XCTest

final class StampboxUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddEntryFlow() {
        app.buttons["addEntryButton"].tap()
        let nameField = app.textFields["entryNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("UI Test Entry")
        app.buttons["entrySaveButton"].tap()
        XCTAssertTrue(app.staticTexts["UI Test Entry"].waitForExistence(timeout: 2))
    }

    func testFreeLimitTriggersPaywall() {
        for i in 0..<40 {
            app.buttons["addEntryButton"].tap()
            let nameField = app.textFields["entryNameField"]
            if !nameField.waitForExistence(timeout: 1) { break }
            nameField.tap()
            nameField.typeText("Entry \(i)")
            app.buttons["entrySaveButton"].tap()
        }
        app.buttons["addEntryButton"].tap()
        XCTAssertTrue(app.buttons["paywallPurchaseButton"].waitForExistence(timeout: 2) ||
                      app.buttons["paywallDismissButton"].waitForExistence(timeout: 2))
    }

    func testKeyboardDismissOnTapOutside() {
        app.buttons["addEntryButton"].tap()
        let nameField = app.textFields["entryNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Dismiss Test")
        app.staticTexts["Stamp"].firstMatch.tap()
        XCTAssertFalse(app.keyboards.element.exists)
    }

    func testSettingsSheetOpens() {
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["settingsDoneButton"].waitForExistence(timeout: 2))
        app.buttons["settingsDoneButton"].tap()
    }
}
