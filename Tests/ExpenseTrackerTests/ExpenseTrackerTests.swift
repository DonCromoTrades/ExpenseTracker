import XCTest
@testable import ExpenseTracker

final class ExpenseTrackerTests: XCTestCase {
    func testExample() throws {
        // Placeholder test to establish structure
        XCTAssertTrue(true)
    }

#if canImport(CoreData)
    func testInitializationFailsWithInvalidStoreURL() throws {
        let invalidURL = URL(fileURLWithPath: "/invalid/path/store.sqlite")
        XCTAssertThrowsError(try PersistenceController(storeURL: invalidURL))
    }
#endif
}
