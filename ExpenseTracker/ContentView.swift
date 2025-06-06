import SwiftUI
import DataVisualizer
import ExpenseStore
import CoreData
import SwiftData
import UserAuth

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var userManager = UserManager()

    var body: some View {
        if userManager.currentUser != nil {
            TabView {
                NavigationView { ExpensesChartView() }
                    .environment(\.modelContext, context)
                    .tabItem { Label("Charts", systemImage: "chart.bar") }
                NavigationView { ExpenseListView() }
                    .environment(\.modelContext, context)
                    .tabItem { Label("Expenses", systemImage: "list.bullet") }
                NavigationView { BudgetListView() }
                    .environment(\.modelContext, context)
                    .tabItem { Label("Budgets", systemImage: "dollarsign.circle") }
                NavigationView { BudgetProgressView() }
                    .environment(\.modelContext, context)
                    .tabItem { Label("Progress", systemImage: "chart.pie") }
                NavigationView { RecurringExpenseListView() }
                    .environment(\.modelContext, context)
                    .tabItem { Label("Recurring", systemImage: "repeat") }
                NavigationView { ReceiptCaptureView() }
                    .environment(\.modelContext, context)
                    .tabItem { Label("Scan", systemImage: "camera") }
            }
        } else {
            SignInView(manager: userManager)
        }
    }
}

#Preview {
    let controller = PersistenceController(inMemory: true)
    let context = controller.container.viewContext
    for i in 0..<5 {
        let exp = Expense(context: context)
        exp.id = UUID()
        exp.title = "Sample \(i)"
        exp.amount = Double.random(in: 5...50)
        exp.date = Calendar.current.date(byAdding: .month, value: -i, to: Date())!
    }
    try? context.save()
    return ContentView().environment(\.modelContext, context)
}
