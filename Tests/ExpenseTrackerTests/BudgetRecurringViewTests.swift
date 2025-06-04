#if canImport(SwiftUI) && canImport(CoreData)
import XCTest
import SwiftUI
@testable import ExpenseTracker
import ExpenseStore

final class BudgetRecurringViewTests: XCTestCase {
    func testBudgetListViewInit() {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.viewContext
        let view = BudgetListView(persistence: controller).environment(\.managedObjectContext, ctx)
        XCTAssertNotNil(view)
    }

    func testRecurringExpenseListViewInit() {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.viewContext
        let view = RecurringExpenseListView(persistence: controller).environment(\.managedObjectContext, ctx)
        XCTAssertNotNil(view)
    }

    func testReceiptCaptureViewInit() {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.viewContext
        let view = ReceiptCaptureView(persistence: controller).environment(\.managedObjectContext, ctx)
        XCTAssertNotNil(view)
    }
}
#endif
