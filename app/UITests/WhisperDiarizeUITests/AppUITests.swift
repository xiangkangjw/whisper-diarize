import XCTest

@MainActor
final class AppUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // MARK: - Launch

    func testAppLaunches() {
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }

    // MARK: - Drop Zone

    func testDropZoneVisible() {
        XCTAssertTrue(app.staticTexts["Drop audio here"].waitForExistence(timeout: 5))
    }

    func testChooseFileButtonExists() {
        XCTAssertTrue(app.buttons["Choose File…"].waitForExistence(timeout: 5))
    }

    func testOpenSettingsButtonExists() {
        XCTAssertTrue(app.buttons["Open Settings"].waitForExistence(timeout: 5))
    }

    // MARK: - Settings

    func testSettingsOpensWithButton() {
        let settingsBtn = app.buttons["Open Settings"]
        XCTAssertTrue(settingsBtn.waitForExistence(timeout: 5))
        settingsBtn.click()
        XCTAssertTrue(app.windows.matching(NSPredicate(format: "title CONTAINS 'Settings'")).firstMatch
            .waitForExistence(timeout: 3))
    }

    func testSettingsOpensWithKeyboardShortcut() {
        app.typeKey(",", modifierFlags: .command)
        XCTAssertTrue(app.windows.matching(NSPredicate(format: "title CONTAINS 'Settings'")).firstMatch
            .waitForExistence(timeout: 3))
    }

    func testSettingsContainsTokenField() {
        app.typeKey(",", modifierFlags: .command)
        let settingsWindow = app.windows.matching(NSPredicate(format: "title CONTAINS 'Settings'")).firstMatch
        XCTAssertTrue(settingsWindow.waitForExistence(timeout: 3))
        XCTAssertTrue(settingsWindow.secureTextFields.firstMatch.exists)
    }

    // MARK: - Toolbar

    func testToolbarHasNoActionsOnIdleState() {
        XCTAssertFalse(app.buttons["Copy"].exists)
        XCTAssertFalse(app.buttons["Save…"].exists)
        XCTAssertFalse(app.buttons["Cancel"].exists)
    }
}
