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

    func testScanWithCropAndPreprocess() {
        let size = CGSize(width: 300, height: 150)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            UIColor.black.setFill()
            ctx.fill(CGRect(x: 50, y: 40, width: 200, height: 60))
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 25),
                .foregroundColor: UIColor.white
            ]
            NSString(string: "Subtotal").draw(at: CGPoint(x: 60, y: 55), withAttributes: attributes)
        }

        let crop = CGRect(x: 50, y: 40, width: 200, height: 60)
        let expectation = expectation(description: "scanning")
        let scanner = ReceiptScanner()
        scanner.scan(image: image, cropRect: crop, preprocess: true) { result in
            switch result {
            case .success(let texts):
                XCTAssertTrue(texts.contains { $0.contains("Subtotal") })
            case .failure(let error):
                XCTFail("Scan failed with error: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
}
#endif
