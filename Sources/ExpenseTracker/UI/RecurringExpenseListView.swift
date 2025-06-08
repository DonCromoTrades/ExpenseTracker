#if canImport(SwiftUI) && canImport(SwiftData)
import SwiftUI
import SwiftData
import ExpenseStore

@available(iOS 17.0, macOS 14.0, *)
struct RecurringExpenseListView: View {
    @Environment(\.modelContext) private var context
    private let persistence: PersistenceController

    @Query(sort: [SortDescriptor<RecurringExpense>(\.startDate)])
    private var expenses: [RecurringExpense]

    @State private var showEditor = false
    @State private var editingExpense: RecurringExpense?

    init(persistence: PersistenceController? = nil) {
        self.persistence = persistence ?? RecurringExpenseListView.defaultPersistence
    }

    @MainActor
    private static var defaultPersistence: PersistenceController {
        PersistenceController.shared
    }

    var body: some View {
        List {
            ForEach(expenses, id: \.id) { expense in
                VStack(alignment: .leading) {
                    Text(expense.title)
                    HStack {
                        Text(expense.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        Spacer()
                        Text(expense.frequency)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    editingExpense = expense
                    showEditor = true
                }
            }
            .onDelete(perform: removeExpense)
        }
        .navigationTitle("Recurring Expenses")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    editingExpense = nil
                    showEditor = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            if let expense = editingExpense {
                RecurringExpenseEditView(expense: expense)
                    .environment(\.modelContext, context)
            } else {
                RecurringExpenseEditView(
                    expense: RecurringExpense(title: "", amount: 0, startDate: Date(), frequency: "daily")
                )
                .environment(\.modelContext, context)
            }
        }
        } // ← This closes the body property

        private func removeExpense(at offsets: IndexSet) {
            for index in offsets {
                let expense = expenses[index]
                context.delete(expense)
            }
            try? context.save()
    }
}
#endif
