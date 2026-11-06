import XCTest

final class HelloAppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws { }

    @MainActor
    func testLanguageSwitchAndLogin() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-reset-state"]
        app.launch()

        let langButton = app.buttons["languageSwitchButton"]
        XCTAssertTrue(langButton.waitForExistence(timeout: 2))
        langButton.tap()

        let loginTitle = app.staticTexts["loginTitle"]
        XCTAssertTrue(loginTitle.waitForExistence(timeout: 2))
        XCTAssertEqual(loginTitle.label, "Login")

        let emailField = app.textFields["emailField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 2))
        emailField.tap()
        emailField.typeText("test12@mail.ru")

        let passwordField = app.secureTextFields["passwordField"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 2))
        passwordField.tap()
        passwordField.typeText("a12345")

        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 2))
        loginButton.tap()

        let homeTitle = app.staticTexts["homeTitle"]
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 5))

        XCTAssertEqual(homeTitle.label, "Welcome")
        let recommended = app.staticTexts["recommendedTitle"]
        XCTAssertEqual(recommended.label, "Recommended paintings")
    }


    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
