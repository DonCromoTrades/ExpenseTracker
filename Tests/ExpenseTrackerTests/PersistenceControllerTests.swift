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
        expense.frequency = .weekly

        try context.save()

        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        var results = try context.fetch(request)
        XCTAssertEqual(results.count, 1)
        if let first = results.first {
            XCTAssertEqual(first.title, "Lunch")
            XCTAssertEqual(first.category, "Food")
            XCTAssertEqual(first.tags ?? [], ["meal", "lunch"])
            XCTAssertEqual(first.notes, "Paid by cash")
            XCTAssertEqual(first.frequency, .weekly)
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
        let ctx = controller.container.viewContext

        // Recurring Expense
        let recurring = try controller.addRecurringExpense(title: "Gym", amount: 50, startDate: Date(), frequency: "Weekly")

        var reFetch: [RecurringExpense] = try ctx.fetch(RecurringExpense.fetchRequest())
        XCTAssertEqual(reFetch.count, 1)
        XCTAssertEqual(reFetch.first?.title, "Gym")

        try controller.deleteRecurringExpense(recurring)
        reFetch = try ctx.fetch(RecurringExpense.fetchRequest())
        XCTAssertEqual(reFetch.count, 0)

        // Budget
        let budget = try controller.addBudget(category: "Food", limit: 200)
        var bFetch: [Budget] = try ctx.fetch(Budget.fetchRequest())
        XCTAssertEqual(bFetch.count, 1)
        XCTAssertEqual(bFetch.first?.category, "Food")

        try controller.deleteBudget(budget)
        bFetch = try ctx.fetch(Budget.fetchRequest())
        XCTAssertEqual(bFetch.count, 0)
    }
}
#endif
