import XCTest
@testable import UserAuth

final class UserManagerTests: XCTestCase {
    func testLocalSignInStoresUser() {
        let manager = UserManager()
        manager.signInLocally(name: "Alice")
        XCTAssertEqual(manager.currentUser?.name, "Alice")
    }
}
