import XCTest
import DataVisualizer
import ExpenseStore

@testable import ExpenseTracker

final class ExpenseTrackerTests: XCTestCase {
    func testChartViewInitialization() throws {
        #if canImport(CoreData)
        let context = PersistenceController(inMemory: true).container.viewContext
        _ = ExpensesChartView(context: context)
        #else
        _ = ExpensesChartView(context: nil)
        #endif
        XCTAssertTrue(true)
    }
}
