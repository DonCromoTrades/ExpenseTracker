#if canImport(SwiftUI) && canImport(SwiftData)
import SwiftUI
import SwiftData
import ExpenseStore

@available(iOS 17.0, macOS 14.0, *)
public struct ExpensesChartView: View {
    @Environment(\.modelContext) private var context

    @Query(sort: [SortDescriptor(\.date)]) private var expenses: [Expense]
  

    public init() {}

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

    /// Returns the total expense amounts grouped by month, in ascending order.
    /// This helper is exposed for testing purposes.
    public func monthlyTotalValuesForTesting(in context: ModelContext) -> [Double] {
let descriptor = FetchDescriptor<Expense>(sortBy: [SortDescriptor(\.date, order: .forward)])

        do {
            let results = try context.fetch(descriptor)
            let calendar = Calendar.current
            let grouped = Dictionary(grouping: results) { expense -> Date in
                calendar.date(from: calendar.dateComponents([.year, .month], from: expense.date)) ?? expense.date
            }
            return grouped
                .sorted { $0.key < $1.key }
                .map { (_, expenses) in expenses.reduce(0) { $0 + $1.amount } }
        } catch {
            return []
        }
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
    public init() {}

    public func monthlyTotalValuesForTesting(in context: Any? = nil) -> [Double] { [] }
}
#endif
