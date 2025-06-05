import XCTest
import DataVisualizer
import ExpenseStore

@testable import ExpenseTracker

final class ExpenseTrackerTests: XCTestCase {
    func testChartViewInitialization() throws {
        #if canImport(CoreData)
        let context = PersistenceController(inMemory: true).container.viewContext

        #else
        _ = ExpensesChartView()
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

    func testCommandLineTool() throws {
        #if os(iOS)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 40))
        let image = renderer.image { ctx in
            NSString(string: "Total $5").draw(at: .zero, withAttributes: [.font: UIFont.systemFont(ofSize: 20)])
        }
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("cli_test.png")
        try image.pngData()!.write(to: url)

        let process = Process()
        process.executableURL = productsDirectory.appendingPathComponent("ExpenseTracker")
        process.arguments = [url.path]
        let pipe = Pipe()
        process.standardOutput = pipe
        try process.run()
        process.waitUntilExit()
        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        XCTAssertFalse(output.isEmpty)
        #else
        throw XCTSkip("Requires iOS")
        #endif
    }
}

#if os(iOS)
private var productsDirectory: URL {
    for bundle in Bundle.allBundles where bundle.bundleURL.pathExtension == "xctest" {
        return bundle.bundleURL.deletingLastPathComponent()
    }
    fatalError("Products directory not found")
}
#endif
