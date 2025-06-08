import SwiftUI
import SwiftData
import ExpenseStore

public struct RecurringExpenseEditView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Bindable public var expense: RecurringExpense
    @State private var amountString = ""

    public init(expense: RecurringExpense) {
        self._expense = Bindable(wrappedValue: expense)
    }

    public var body: some View {
        Form {
            TextField("Title", text: $expense.title)

            TextField("Amount", text: $amountString)
                .textContentType(.none)
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
                .onChange(of: amountString) {
                    let filtered = amountString.filter { "0123456789.".contains($0) }
                    if amountString != filtered {
                        amountString = filtered
                    }
                }

            TextField("Frequency", text: $expense.frequency)
        }
        .onAppear {
            amountString = String(expense.amount)
        }
        .navigationTitle("Edit Recurring Expense")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    if let number = Double(amountString) {
                        expense.amount = number
                        try? context.save()
                        dismiss()
                    } else {
                        // Optionally show validation alert here
                    }
                }
            }
        }
    }
}
