#if canImport(SwiftUI) && canImport(SwiftData)
import XCTest
import SwiftUI
import SwiftData
import ExpenseStore
@testable import DataVisualizer

final class ExpensesChartViewTests: XCTestCase {
    func testViewInitialization() {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.mainContext
        let view = ExpensesChartView().environment(\.modelContext, ctx)
        XCTAssertNotNil(view)
    }

    func testMonthlyTotalsSummarization() throws {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.mainContext

        func makeExpense(amount: Double, date: Date) {
            let expense = Expense(title: "tmp", amount: amount, date: date)
            ctx.insert(expense)
        }

        let cal = Calendar.current
        makeExpense(amount: 10, date: cal.date(from: DateComponents(year: 2023, month: 1, day: 1))!)
        makeExpense(amount: 20, date: cal.date(from: DateComponents(year: 2023, month: 1, day: 5))!)
        makeExpense(amount: 5,  date: cal.date(from: DateComponents(year: 2023, month: 2, day: 3))!)
        makeExpense(amount: 15, date: cal.date(from: DateComponents(year: 2023, month: 2, day: 10))!)

        try ctx.save()

        let totals = ExpensesChartView().monthlyTotalValuesForTesting(in: ctx)
        XCTAssertEqual(totals, [30, 20])
    }
}
#endif
