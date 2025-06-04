#if canImport(UIKit) && canImport(Vision)
import XCTest
import UIKit
@testable import ReceiptScanner

final class ReceiptScannerTests: XCTestCase {
    func testScanExtractsText() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 50))
        let image = renderer.image { ctx in
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20)
            ]
            let text = NSString(string: "Total $5")
            text.draw(at: CGPoint(x: 10, y: 10), withAttributes: attributes)
        }

        let expectation = expectation(description: "scanning")
        let scanner = ReceiptScanner()
        scanner.scan(image: image) { result in
            switch result {
            case .success(let texts):
                XCTAssertTrue(texts.contains { $0.contains("Total") })
            case .failure(let error):
                XCTFail("Scan failed with error: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
}
#endif
