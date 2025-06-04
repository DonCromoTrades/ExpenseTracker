import SwiftUI
import DataVisualizer
import ExpenseStore
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        ExpensesChartView(context: context)
            .padding()
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    return ContentView()
        .environment(\.managedObjectContext, context)
}
