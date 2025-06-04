#if canImport(SwiftUI) && canImport(CoreData)
import SwiftUI
import CoreData
import ExpenseStore

struct RecurringExpenseListView: View {
    @Environment(\.managedObjectContext) private var context
    private let persistence: PersistenceController
    @FetchRequest(
        entity: RecurringExpense.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \RecurringExpense.startDate, ascending: true)],
        animation: .default
    ) private var expenses: FetchedResults<RecurringExpense>

    @State private var showEditor = false
    @State private var editingExpense: RecurringExpense?

    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
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
        .navigationTitle("Recurring")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { editingExpense = nil; showEditor = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            RecurringExpenseEditView(expense: editingExpense, persistence: persistence)
                .environment(\.managedObjectContext, context)
        }
    }

    private func removeExpense(at offsets: IndexSet) {
        for index in offsets {
            let ex = expenses[index]
            try? persistence.deleteRecurringExpense(ex)
        }
    }
}

struct RecurringExpenseEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    private let persistence: PersistenceController
    var expense: RecurringExpense?

    @State private var title: String
    @State private var amount: String
    @State private var startDate: Date
    @State private var frequency: RecurrenceFrequency

    init(expense: RecurringExpense? = nil, persistence: PersistenceController = .shared) {
        self.expense = expense
        self.persistence = persistence
        _title = State(initialValue: expense?.title ?? "")
        _amount = State(initialValue: expense.map { String($0.amount) } ?? "")
        _startDate = State(initialValue: expense?.startDate ?? Date())
        _frequency = State(initialValue: RecurrenceFrequency(rawValue: expense?.frequency ?? "") ?? .monthly)
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                Picker("Frequency", selection: $frequency) {
                    ForEach(RecurrenceFrequency.allCases, id: \.self) { f in
                        Text(f.rawValue.capitalized).tag(f)
                    }
                }
            }
            .navigationTitle(expense == nil ? "Add Recurring" : "Edit Recurring")
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
                exp.startDate = startDate
                exp.nextDate = startDate
                exp.frequency = frequency.rawValue
                try context.save()
            } else {
                _ = try persistence.addRecurringExpense(title: title, amount: amt, startDate: startDate, frequency: frequency.rawValue)
            }
            dismiss()
        } catch {
            print("Save error: \(error)")
        }
    }
}

#Preview {
    let controller = PersistenceController(inMemory: true)
    let ctx = controller.container.viewContext
    _ = try? controller.addRecurringExpense(title: "Gym", amount: 50, startDate: Date(), frequency: "Weekly")
    return NavigationView { RecurringExpenseListView(persistence: controller) }
        .environment(\.managedObjectContext, ctx)
}
#endif
