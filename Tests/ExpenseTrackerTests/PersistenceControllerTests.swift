#if canImport(SwiftData)
import XCTest
import SwiftData
import ExpenseStore

final class PersistenceControllerTests: XCTestCase {
    @MainActor
    func testCRUDOperations() throws {
        let container = try ModelContainer(for: ExpenseModel.self,
                                           RecurringExpenseModel.self,
                                           BudgetModel.self,
                                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext

        let expense = ExpenseModel(title: "Lunch", amount: 9.99, date: Date(), category: "Food", tags: ["meal", "lunch"], notes: "Paid by cash", frequency: .weekly)
        context.insert(expense)
        try context.save()

        let descriptor = FetchDescriptor<ExpenseModel>()
        var results = try context.fetch(descriptor)
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

        results = try context.fetch(descriptor)
        XCTAssertEqual(results.count, 0)
    }

    @MainActor
    func testRecurringAndBudgetHelpers() throws {
        let container = try ModelContainer(for: ExpenseModel.self,
                                           RecurringExpenseModel.self,
                                           BudgetModel.self,
                                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let ctx = container.mainContext

        // Recurring Expense
        let recurring = RecurringExpenseModel(title: "Gym", amount: 50, startDate: Date(), frequency: "Weekly")
        ctx.insert(recurring)

        var reFetch = try ctx.fetch(FetchDescriptor<RecurringExpenseModel>())
        XCTAssertEqual(reFetch.count, 1)
        XCTAssertEqual(reFetch.first?.title, "Gym")

        ctx.delete(recurring)
        reFetch = try ctx.fetch(FetchDescriptor<RecurringExpenseModel>())
        XCTAssertEqual(reFetch.count, 0)

        // Budget
        let budget = BudgetModel(category: "Food", limit: 200)
        ctx.insert(budget)
        var bFetch = try ctx.fetch(FetchDescriptor<BudgetModel>())
        XCTAssertEqual(bFetch.count, 1)
        XCTAssertEqual(bFetch.first?.category, "Food")

        ctx.delete(budget)
        bFetch = try ctx.fetch(FetchDescriptor<BudgetModel>())
        XCTAssertEqual(bFetch.count, 0)
    }

    @MainActor
    func testAddRecurringExpenseCreatesObject() throws {
        let container = try ModelContainer(for: ExpenseModel.self,
                                           RecurringExpenseModel.self,
                                           BudgetModel.self,
                                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let ctx = container.mainContext
        let start = Date()

        let recurring = RecurringExpenseModel(title: "Internet", amount: 60, startDate: start, frequency: "Monthly")
        ctx.insert(recurring)

        let fetch = try ctx.fetch(FetchDescriptor<RecurringExpenseModel>())
        XCTAssertEqual(fetch.count, 1)
        if let first = fetch.first {
            XCTAssertEqual(first.id, recurring.id)
            XCTAssertEqual(first.title, "Internet")
            XCTAssertEqual(first.amount, 60)
            XCTAssertEqual(first.startDate, start)
            XCTAssertEqual(first.frequency, "Monthly")
        }
    }

    @MainActor
    func testAddBudgetCreatesObject() throws {
        let container = try ModelContainer(for: ExpenseModel.self,
                                           RecurringExpenseModel.self,
                                           BudgetModel.self,
                                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let ctx = container.mainContext

        let budget = BudgetModel(category: "Travel", limit: 500)
        ctx.insert(budget)

        let fetch = try ctx.fetch(FetchDescriptor<BudgetModel>())
        XCTAssertEqual(fetch.count, 1)
        if let first = fetch.first {
            XCTAssertEqual(first.id, budget.id)
            XCTAssertEqual(first.category, "Travel")
            XCTAssertEqual(first.limit, 500)
        }
    }

    @MainActor
    func testAddExpenseCreatesObject() throws {
        let container = try ModelContainer(for: ExpenseModel.self,
                                           RecurringExpenseModel.self,
                                           BudgetModel.self,
                                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let ctx = container.mainContext
        let date = Date()

        let expense = ExpenseModel(title: "Coffee", amount: 3.5, date: date, category: "Food")
        ctx.insert(expense)

        let fetch = try ctx.fetch(FetchDescriptor<ExpenseModel>())
        XCTAssertEqual(fetch.count, 1)
        if let first = fetch.first {
            XCTAssertEqual(first.id, expense.id)
            XCTAssertEqual(first.title, "Coffee")
            XCTAssertEqual(first.amount, 3.5)
            XCTAssertEqual(first.date, date)
            XCTAssertEqual(first.category, "Food")
        }
    }
}
#endif
