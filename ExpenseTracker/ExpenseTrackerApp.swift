import SwiftUI
import ExpenseStore

@main
struct ExpenseTrackerApp: App {
    let persistenceController = PersistenceController.shared
    let scheduler: RecurringExpenseScheduler

    init() {
        scheduler = RecurringExpenseScheduler(context: persistenceController.container.viewContext)
        do {
            try scheduler.processDueExpenses()
        } catch {
            print("Failed to process recurring expenses: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
#if canImport(CloudKit)
                    persistenceController.fetchCloudUpdates()
#endif
                }
        }
    }
}
