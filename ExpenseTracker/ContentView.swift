import SwiftUI
import DataVisualizer
import ExpenseStore
import CoreData
import UserAuth

struct ContentView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var userManager = UserManager()
    @EnvironmentObject private var syncController: SyncController

    private var syncErrorBinding: Binding<Bool> {
        Binding(
            get: { syncController.lastError != nil },
            set: { if !$0 { syncController.lastError = nil } }
        )
    }

    var body: some View {
        Group {
            if userManager.currentUser != nil {
                TabView {
                    NavigationView { ExpensesChartView(context: context) }
                        .tabItem { Label("Charts", systemImage: "chart.bar") }
                    NavigationView { ExpenseListView() }
                        .environment(\.managedObjectContext, context)
                        .tabItem { Label("Expenses", systemImage: "list.bullet") }
                    NavigationView { BudgetListView() }
                        .environment(\.managedObjectContext, context)
                        .tabItem { Label("Budgets", systemImage: "dollarsign.circle") }
                    NavigationView { RecurringExpenseListView() }
                        .environment(\.managedObjectContext, context)
                        .tabItem { Label("Recurring", systemImage: "repeat") }
                    NavigationView { ReceiptCaptureView() }
                        .tabItem { Label("Scan", systemImage: "camera") }
                }
            } else {
                SignInView(manager: userManager)
            }
        }
        .alert("Sync Error", isPresented: syncErrorBinding) {
            Button("OK", role: .cancel) { syncController.lastError = nil }
        } message: {
            Text(syncController.lastError?.localizedDescription ?? "")
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
    return ContentView()
        .environment(\.managedObjectContext, context)
        .environmentObject(SyncController())
}
