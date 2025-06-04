#if canImport(SwiftUI) && canImport(CoreData)
import SwiftUI
import CoreData
import ExpenseStore

struct BudgetProgressView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: Budget.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Budget.category, ascending: true)],
        animation: .default
    ) private var budgets: FetchedResults<Budget>

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
        let req: NSFetchRequest<Expense> = Expense.fetchRequest()
        let cal = Calendar.current
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: Date())) ?? Date()
        let nextMonth = cal.date(byAdding: .month, value: 1, to: startOfMonth) ?? Date()
        req.predicate = NSPredicate(format: "category == %@ AND date >= %@ AND date < %@", budget.category, startOfMonth as NSDate, nextMonth as NSDate)
        let expenses = (try? context.fetch(req)) ?? []
        return expenses.reduce(0) { $0 + $1.amount }
    }
}
#endif
