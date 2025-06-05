import SwiftUI
import DataVisualizer
import ExpenseStore
import CoreData
import UserAuth

struct ContentView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var userManager = UserManager()

    var body: some View {
        if userManager.currentUser != nil {
            TabView {
                NavigationView { ExpensesChartView() }
                    .environment(\.managedObjectContext, context)
                    .tabItem { Label("Charts", systemImage: "chart.bar") }
                NavigationView { ExpenseListView() }
                    .environment(\.managedObjectContext, context)
                    .tabItem { Label("Expenses", systemImage: "list.bullet") }
                NavigationView { BudgetListView() }
                    .environment(\.managedObjectContext, context)
                    .tabItem { Label("Budgets", systemImage: "dollarsign.circle") }
                NavigationView { BudgetProgressView() }
                    .environment(\.managedObjectContext, context)
                    .tabItem { Label("Progress", systemImage: "chart.pie") }
                NavigationView { RecurringExpenseListView() }
                    .environment(\.managedObjectContext, context)
                    .tabItem { Label("Recurring", systemImage: "repeat") }
                NavigationView { ReceiptCaptureView() }
                    .environment(\.managedObjectContext, context)
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
    return ContentView().environment(\.managedObjectContext, context)
}
