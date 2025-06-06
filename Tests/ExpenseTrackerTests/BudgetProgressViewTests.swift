#if canImport(SwiftUI)
import XCTest
import SwiftUI
@testable import ExpenseTracker
import ExpenseStore

final class BudgetProgressViewTests: XCTestCase {
    func testViewInitialization() {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.viewContext
        let view = BudgetProgressView().environment(\.modelContext, ctx)
        XCTAssertNotNil(view)
    }
}
#endif
