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

        // RecurringExpense helpers
        try controller.addRecurringExpense(title: "Gym", amount: 29.99, frequency: "monthly")
        let rRequest: NSFetchRequest<RecurringExpense> = RecurringExpense.fetchRequest()
        var recurring = try context.fetch(rRequest)
        XCTAssertEqual(recurring.count, 1)
        XCTAssertEqual(recurring.first?.title, "Gym")

        if let firstRecurring = recurring.first {
            try controller.deleteRecurringExpense(firstRecurring)
        }
        recurring = try context.fetch(rRequest)
        XCTAssertEqual(recurring.count, 0)

        // Budget helpers
        try controller.addBudget(category: "Food", limit: 200)
        let bRequest: NSFetchRequest<Budget> = Budget.fetchRequest()
        var budgets = try context.fetch(bRequest)
        XCTAssertEqual(budgets.count, 1)
        XCTAssertEqual(budgets.first?.category, "Food")

        if let firstBudget = budgets.first {
            try controller.deleteBudget(firstBudget)
        }
        budgets = try context.fetch(bRequest)
        XCTAssertEqual(budgets.count, 0)
    }
}
#endif
