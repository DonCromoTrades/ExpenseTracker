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

    func testScanRotatedImage() throws {
#if os(iOS)
        let text = "Hello"
        let font = UIFont.systemFont(ofSize: 40)
        let size = (text as NSString).size(withAttributes: [.font: font])
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        defer { UIGraphicsEndImageContext() }
        (text as NSString).draw(at: .zero, withAttributes: [.font: font])
        guard let baseImage = UIGraphicsGetImageFromCurrentImageContext() else {
            XCTFail("Failed to create base image")
            return
        }
        let rotated = UIImage(cgImage: baseImage.cgImage!, scale: 1, orientation: .right)

        let expectation = expectation(description: "scan")
        ReceiptScanner().scan(image: rotated) { result in
            switch result {
            case .success(let data):
                XCTAssertTrue(data.lines.contains(where: { $0.contains(text) }))
            case .failure(let error):
                XCTFail("Scanning failed: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
#else
        throw XCTSkip("Requires iOS")
#endif
    }
}
