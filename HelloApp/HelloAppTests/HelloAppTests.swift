import Testing
@testable import HelloApp

struct EmailValidationTests {

    @Test func validEmailShouldPass() async throws {
        #expect(ValidationService.isValidEmail("example@mail.com") == true)
        #expect(ValidationService.isValidEmail("user.test123@domain.org") == true)
    }

    @Test func invalidEmailShouldFail() async throws {
        #expect(ValidationService.isValidEmail("wrong-email") == false)
        #expect(ValidationService.isValidEmail("abc@") == false)
        #expect(ValidationService.isValidEmail("@mail.com") == false)
        #expect(ValidationService.isValidEmail("test@mail") == false)
    }
}




