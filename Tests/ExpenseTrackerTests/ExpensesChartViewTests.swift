#if canImport(SwiftUI)
import XCTest
import SwiftUI
@testable import DataVisualizer

final class ExpensesChartViewTests: XCTestCase {
    func testViewInitialization() {
        let view = ExpensesChartView()
        XCTAssertNotNil(view)
    }
}
#endif
