#if canImport(SwiftUI) && canImport(SwiftData)
import SwiftUI
import SwiftData
import ExpenseStore

@available(iOS 17.0, macOS 14.0, *)
struct BudgetListView: View {
    @Environment(\.modelContext) private var context
    
    private let persistence: PersistenceController
  
    @Query(sort: [SortDescriptor(\.category)]) private var budgets: [Budget]


    @State private var showEditor = false
    @State private var editingBudget: Budget?

    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
    }

    var body: some View {
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { editingBudget = nil; showEditor = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            BudgetEditView(budget: editingBudget, persistence: persistence)
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

struct BudgetEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    private let persistence: PersistenceController
    var budget: Budget?

    @State private var category: String
    @State private var limit: String

    init(budget: Budget? = nil, persistence: PersistenceController = .shared) {
        self.budget = budget
        self.persistence = persistence
        _category = State(initialValue: budget?.category ?? "")
        _limit = State(initialValue: budget.map { String($0.limit) } ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Category", text: $category)
                TextField("Limit", text: $limit)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle(budget == nil ? "Add Budget" : "Edit Budget")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { save() }
                }
            }
        }
    }

    private func save() {
        guard let amount = Double(limit) else { return }
        do {
            if let budget = budget {
                budget.category = category
                budget.limit = amount
            } else {
                let budget = Budget(category: category, limit: amount)
                context.insert(budget)
            }
            try context.save()
            dismiss()
        } catch {
            print("Save error: \(error)")
        }
    }
}

#Preview {
    let controller = PersistenceController(inMemory: true)
    let ctx = controller.container.mainContext
    _ = try? controller.addBudget(category: "Food", limit: 200)
    return NavigationView { BudgetListView(persistence: controller) }
        .environment(\.modelContext, ctx)
}
#endif
