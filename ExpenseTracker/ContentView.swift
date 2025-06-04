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
                NavigationView { ExpensesChartView(context: context) }
                    .tabItem { Label("Charts", systemImage: "chart.bar") }
                NavigationView { ExpenseListView() }
                    .environment(\.managedObjectContext, context)
                    .tabItem { Label("Expenses", systemImage: "list.bullet") }
                NavigationView { ReceiptCaptureView() }
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
