#if canImport(CoreData)
import XCTest
import CoreData
@testable import ExpenseStore

final class PersistenceControllerTests: XCTestCase {
    func testCRUDOperations() throws {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        let expense = Expense(context: context)
        expense.id = UUID()
        expense.title = "Lunch"
        expense.amount = 9.99
        expense.date = Date()
        expense.category = "Food"
        expense.tags = ["meal", "lunch"]
        expense.notes = "Paid by cash"

        try context.save()

        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        var results = try context.fetch(request)
        XCTAssertEqual(results.count, 1)
        if let first = results.first {
            XCTAssertEqual(first.title, "Lunch")
            XCTAssertEqual(first.category, "Food")
            XCTAssertEqual(first.tags ?? [], ["meal", "lunch"])
            XCTAssertEqual(first.notes, "Paid by cash")
        }

        if let fetchedExpense = results.first {
            context.delete(fetchedExpense)
            try context.save()
        }

        results = try context.fetch(request)
        XCTAssertEqual(results.count, 0)
    }

    func testRecurringAndBudgetHelpers() throws {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        // Recurring Expense
        let recurring = controller.addRecurringExpense(title: "Gym", amount: 30, frequency: "Monthly")
        let recRequest: NSFetchRequest<RecurringExpense> = RecurringExpense.fetchRequest()
        var recResults = try context.fetch(recRequest)
        XCTAssertEqual(recResults.count, 1)
        controller.deleteRecurringExpense(recurring)
        recResults = try context.fetch(recRequest)
        XCTAssertEqual(recResults.count, 0)

        // Budget
        let budget = controller.addBudget(category: "Food", limit: 200)
        let budReq: NSFetchRequest<Budget> = Budget.fetchRequest()
        var budResults = try context.fetch(budReq)
        XCTAssertEqual(budResults.count, 1)
        controller.deleteBudget(budget)
        budResults = try context.fetch(budReq)
        XCTAssertEqual(budResults.count, 0)
    }
}
#endif
