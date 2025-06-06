#if canImport(SwiftUI) && canImport(SwiftData)
import SwiftUI
import SwiftData
import ExpenseStore

@available(iOS 17.0, macOS 14.0, *)
struct BudgetProgressView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\.category)]) private var budgets: [Budget]

    var body: some View {
        List {
            ForEach(budgets, id: \.id) { budget in
                VStack(alignment: .leading) {
                    Text(budget.category)
                    let spent = spending(for: budget)
                    ProgressView(value: spent, total: budget.limit)
                    let code = Locale.current.currency?.identifier ?? "USD"
                    Text("\(spent, format: .currency(code: code)) of \(budget.limit, format: .currency(code: code))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Budgets")
    }

    private func spending(for budget: Budget) -> Double {
        let cal = Calendar.current
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: Date())) ?? Date()
        let nextMonth = cal.date(byAdding: .month, value: 1, to: startOfMonth) ?? Date()
        let predicate = #Predicate<Expense> { exp in
            exp.category == budget.category && exp.date >= startOfMonth && exp.date < nextMonth
        }
        let descriptor = FetchDescriptor<Expense>(predicate: predicate)
        let expenses = (try? context.fetch(descriptor)) ?? []
        return expenses.reduce(0) { $0 + $1.amount }
    }
}
#endif
