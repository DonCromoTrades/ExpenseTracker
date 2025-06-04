import ReceiptCapture
import DataModel
import ChartsModule
#if canImport(SwiftUI)
import SwiftUI

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
#else
@main
struct ExpenseTrackerApp {
    static func main() {
        print("ExpenseTrackerApp requires SwiftUI")
    }
}
#endif
