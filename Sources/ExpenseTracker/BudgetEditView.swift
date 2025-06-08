import SwiftUI
import SwiftData
import ExpenseStore

public struct BudgetEditView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Bindable public var budget: Budget

    public init(budget: Budget) {
        self._budget = Bindable(wrappedValue: budget)
    }

    public var body: some View {
        Form {
            TextField("Category", text: $budget.category)
            TextField("Limit", value: $budget.limit, format: .number)
                .textFieldStyle(.roundedBorder)
        }
        .navigationTitle("Edit Budget")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    try? context.save()
                    dismiss()
                }
            }
        }
    }
}
