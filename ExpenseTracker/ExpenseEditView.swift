import SwiftUI
import ExpenseStore

struct ExpenseEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    private let persistence: PersistenceController
    var expense: Expense?

    @State private var title: String
    @State private var amount: String
    @State private var date: Date
    @State private var category: String
    @State private var notes: String

    init(expense: Expense? = nil, persistence: PersistenceController = .shared) {
        self.expense = expense
        self.persistence = persistence
        _title = State(initialValue: expense?.title ?? "")
        _amount = State(initialValue: expense.map { String($0.amount) } ?? "")
        _date = State(initialValue: expense?.date ?? Date())
        _category = State(initialValue: expense?.category ?? "")
        _notes = State(initialValue: expense?.notes ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Category", text: $category)
                TextField("Notes", text: $notes)
            }
            .navigationTitle(expense == nil ? "Add Expense" : "Edit Expense")
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
        guard let amt = Double(amount) else { return }
        do {
            if let exp = expense {
                exp.title = title
                exp.amount = amt
                exp.date = date
                exp.category = category.isEmpty ? nil : category
                exp.notes = notes.isEmpty ? nil : notes
                try context.save()
            } else {
                _ = try persistence.addExpense(title: title, amount: amt, date: date, category: category.isEmpty ? nil : category, notes: notes.isEmpty ? nil : notes)
            }
            dismiss()
        } catch {
            print("Save error: \(error)")
        }
    }
}

#if DEBUG
#Preview {
    let controller = PersistenceController(inMemory: true)
    let ctx = controller.container.viewContext
    let exp = Expense(context: ctx)
    exp.id = UUID()
    exp.title = "Coffee"
    exp.amount = 4.5
    exp.date = Date()
    return ExpenseEditView(expense: exp, persistence: controller)
        .environment(\.managedObjectContext, ctx)
}
#endif
