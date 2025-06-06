#if canImport(SwiftUI) && canImport(SwiftData)
import SwiftUI
import SwiftData
import ExpenseStore

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
        let descriptor = FetchDescriptor<Expense>(predicate: #Predicate { $0.category == budget.category && $0.date >= startOfMonth && $0.date < nextMonth })
        let cal = Calendar.current
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: Date())) ?? Date()
        let nextMonth = cal.date(byAdding: .month, value: 1, to: startOfMonth) ?? Date()
        req.predicate = NSPredicate(format: "category == %@ AND date >= %@ AND date < %@", budget.category, startOfMonth as NSDate, nextMonth as NSDate)
        let expenses = (try? context.fetch(descriptor)) ?? []
        return expenses.reduce(0) { $0 + $1.amount }
    }
}
#endif
