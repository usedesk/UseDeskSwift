import XCTest
@testable import Classes

final class ClassesTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Classes().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
