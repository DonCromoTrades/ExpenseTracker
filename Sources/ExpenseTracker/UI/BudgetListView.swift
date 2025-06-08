#if canImport(SwiftUI) && canImport(SwiftData)
import SwiftUI
import SwiftData
import ExpenseStore

@MainActor
public struct BudgetListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Budget.category)]) private var budgets: [Budget]

    @State private var showEditor = false
    @State private var editingBudget: Budget?

    public init() {}

    public var body: some View {
        List {
            ForEach(budgets, id: \.id) { budget in
                VStack(alignment: .leading) {
                    Text(budget.category)
                    Text(budget.limit, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    editingBudget = budget
                    showEditor = true
                }
            }
            .onDelete(perform: removeBudget)
        }
        .navigationTitle("Budgets")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    editingBudget = nil
                    showEditor = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            BudgetEditView(budget: editingBudget ?? Budget(category: "", limit: 0))
                .environment(\.modelContext, context)
        }
    }

    private func removeBudget(at offsets: IndexSet) {
        for index in offsets {
            let budget = budgets[index]
            context.delete(budget)
        }
        try? context.save()
    }
}
#endif
