#if canImport(SwiftUI) && canImport(CoreData)
import SwiftUI
import CoreData
import ExpenseStore

public struct ExpensesChartView: View {
    @FetchRequest private var expenses: FetchedResults<Expense>
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
        _expenses = FetchRequest(
            entity: Expense.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: true)],
            animation: .default,
            predicate: nil,
            managedObjectContext: context
        )
    }

    public var body: some View {
        VStack {
            Text("Expenses: \(expenses.count)")
        }
    }
}
#else
import Foundation

public struct ExpensesChartView {
    public init(context: Any? = nil) {}
}
#endif
