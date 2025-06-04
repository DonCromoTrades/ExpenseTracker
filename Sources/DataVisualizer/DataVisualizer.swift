#if canImport(SwiftUI) && canImport(CoreData)
import SwiftUI
import CoreData
import ExpenseStore

public struct ExpensesChartView: View {
    @FetchRequest private var expenses: FetchedResults<Expense>
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext? = nil) {
        if let ctx = context {
            self.context = ctx
        } else {
            self.context = PersistenceController(inMemory: true).container.viewContext
        }
        _expenses = FetchRequest(
            entity: Expense.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: true)],
            animation: .default,
            predicate: nil,
            managedObjectContext: self.context
        )
    }

    struct MonthTotal: Identifiable {
        let id = UUID()
        let month: Date
        let total: Double
    }

    private var monthlyTotals: [MonthTotal] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: expenses) { expense -> Date in
            calendar.date(from: calendar.dateComponents([.year, .month], from: expense.date)) ?? expense.date
        }
        return grouped.map { (month, expenses) in
            MonthTotal(month: month, total: expenses.reduce(0) { $0 + $1.amount })
        }
        .sorted { $0.month < $1.month }
    }

    private var maxTotal: Double {
        monthlyTotals.map(\.total).max() ?? 0
    }

    private var monthFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM"
        return df
    }

    public var body: some View {
        VStack {
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(monthlyTotals) { item in
                    VStack {
                        Capsule()
                            .fill(Color.accentColor)
                            .frame(height: maxTotal > 0 ? CGFloat(item.total / maxTotal) * 150 : 0)
                        Text(monthFormatter.string(from: item.month))
                            .font(.caption2)
                    }
                }
            }
        }
        .padding()
    }
}
#else
import Foundation

public struct ExpensesChartView {
    public init(context: Any? = nil) {}
}
#endif
