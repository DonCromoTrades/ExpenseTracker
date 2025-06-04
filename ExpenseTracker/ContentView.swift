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
            ExpensesChartView(context: context)
                .padding()
        } else {
            SignInView(manager: userManager)
        }
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    return ContentView()
        .environment(\.managedObjectContext, context)
}
