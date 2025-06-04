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
}
#endif
