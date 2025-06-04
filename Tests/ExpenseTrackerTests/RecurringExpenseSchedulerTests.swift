#if canImport(CoreData)
import XCTest
@testable import ExpenseStore

final class RecurringExpenseSchedulerTests: XCTestCase {
    func testSchedulerCreatesExpenseAndAdvancesDate() throws {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.viewContext
        let initial = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let recurring = try controller.addRecurringExpense(title: "Gym", amount: 50, startDate: initial, frequency: "daily")
        recurring.nextDate = initial
        try ctx.save()

        let scheduler = RecurringExpenseScheduler(context: ctx)
        try scheduler.processDueExpenses(asOf: Date())

        let expReq: NSFetchRequest<Expense> = Expense.fetchRequest()
        let expenses = try ctx.fetch(expReq)
        XCTAssertEqual(expenses.count, 1)
        XCTAssertGreaterThan(recurring.nextDate, initial)
    }
}
#endif
