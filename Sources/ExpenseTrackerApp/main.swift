import SwiftUI
import ReceiptCapture
import DataModel
import ChartsModule

@main
struct ExpenseTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        Text("Expense Tracker")
    }
}
