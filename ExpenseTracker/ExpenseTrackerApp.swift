import SwiftUI
import ExpenseStore

@main
struct ExpenseTrackerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var syncController = SyncController()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(syncController)
                .onAppear { syncController.fetch() }
        }
    }
}
