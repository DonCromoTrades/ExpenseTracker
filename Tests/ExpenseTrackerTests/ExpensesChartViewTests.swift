#if canImport(SwiftUI) && canImport(CoreData)
import XCTest
import SwiftUI
import CoreData
import ExpenseStore
@testable import DataVisualizer

final class ExpensesChartViewTests: XCTestCase {
    func testViewInitialization() {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.viewContext
        let view = ExpensesChartView().environment(\.managedObjectContext, ctx)
        XCTAssertNotNil(view)
    }

    func testMonthlyTotalsSummarization() throws {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.viewContext

        func makeExpense(amount: Double, date: Date) {
            let expense = Expense(context: ctx)
            expense.id = UUID()
            expense.title = "tmp"
            expense.amount = amount
            expense.date = date
        }

        let cal = Calendar.current
        makeExpense(amount: 10, date: cal.date(from: DateComponents(year: 2023, month: 1, day: 1))!)
        makeExpense(amount: 20, date: cal.date(from: DateComponents(year: 2023, month: 1, day: 5))!)
        makeExpense(amount: 5,  date: cal.date(from: DateComponents(year: 2023, month: 2, day: 3))!)
        makeExpense(amount: 15, date: cal.date(from: DateComponents(year: 2023, month: 2, day: 10))!)

        try ctx.save()

<<<<<<< codex/update-test-setup-for-expenseschartview
        let view = ExpensesChartView(context: ctx)
            .environment(\.managedObjectContext, ctx)
        let totals = view.monthlyTotalValuesForTesting()
=======
        let totals = ExpensesChartView().monthlyTotalValuesForTesting(in: ctx)
>>>>>>> main
        XCTAssertEqual(totals, [30, 20])
    }
}
#endif
