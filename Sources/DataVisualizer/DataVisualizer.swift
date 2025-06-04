#if canImport(SwiftUI) && canImport(CoreData)
import SwiftUI
import ExpenseStore

public struct ExpensesChartView: View {
    @FetchRequest(
        entity: Expense.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: true)]
    ) private var expenses: FetchedResults<Expense>

    public init() {}

    public var body: some View {
        VStack {
            Text("Expenses: \(expenses.count)")
        }
    }
}
#else
import Foundation

public struct ExpensesChartView {
    public init() {}
}
#endif
