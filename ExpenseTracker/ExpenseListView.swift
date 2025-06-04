import SwiftUI
import ExpenseStore
import CoreData

struct ExpenseListView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var syncController: SyncController
    @FetchRequest(
        entity: Expense.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)],
        animation: .default
    ) private var fetchedExpenses: FetchedResults<Expense>
    @State private var searchText: String = ""
    @State private var sortOption: SortOption = .date

    enum SortOption: String, CaseIterable, Identifiable {
        case date = "Date"
        case amount = "Amount"
        var id: String { rawValue }
    }

    private var expenses: [Expense] {
        var filtered = fetchedExpenses.filter { searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) }
        switch sortOption {
        case .date:
            filtered.sort { $0.date > $1.date }
        case .amount:
            filtered.sort { $0.amount > $1.amount }
        }
        return filtered
    }

    var body: some View {
        VStack {
            Picker("Sort", selection: $sortOption) {
                ForEach(SortOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding([.horizontal, .top])

            List {
                ForEach(expenses, id: \.id) { expense in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(expense.title)
                            Text(expense.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(expense.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    }
                }
            }
            .searchable(text: $searchText)
        }
        .navigationTitle("Expenses")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { syncController.fetch() }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
}

#Preview {
    let controller = PersistenceController(inMemory: true)
    let viewContext = controller.container.viewContext
    for i in 0..<5 {
        let exp = Expense(context: viewContext)
        exp.id = UUID()
        exp.title = "Item \(i)"
        exp.amount = Double.random(in: 5...100)
        exp.date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
    }
    try? viewContext.save()
    return NavigationView { ExpenseListView().environment(\.managedObjectContext, viewContext) }
}
