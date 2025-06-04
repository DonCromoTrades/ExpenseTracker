#if canImport(UIKit) && canImport(Vision)
import XCTest
import UIKit
@testable import ReceiptScanner

final class ReceiptScannerTests: XCTestCase {
    // Base64 encoded 10x10 PNG with a single black pixel
    static let pngData: Data = Data(base64Encoded:
        "iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAIAAAACUFjqAAAAH0lEQVR4nGP8//8/A27AhEeO3tKMjIz4pNE8QlOnAQDnTwYRH1UVVAAAAABJRU5ErkJggg==")!

    // Base64 encoded two page 3x3 TIFF
    static let tiffData: Data = Data(base64Encoded:
        "SUkqAAgAAAAKAAABBAABAAAAAwAAAAEBBAABAAAAAwAAAAIBAwADAAAAhgAAAAMBAwABAAAAAQAAAAYBAwABAAAAAgAAABEBBAABAAAAjAAAABUBAwABAAAAAwAAABYBBAABAAAAAwAAABcBBAABAAAAGwAAABwBAwABAAAAAQAAALgAAAAIAAgACAD///////////////////////////////////8AAAAAAAAAAABJSSoACAAAAAoAAAEEAAEAAAADAAAAAQEEAAEAAAADAAAAAgEDAAMAAAA2AQAAAwEDAAEAAAABAAAABgEDAAEAAAACAAAAEQEEAAEAAAA8AQAAFQEDAAEAAAADAAAAFgEEAAEAAAADAAAAFwEEAAEAAAAbAAAAHAEDAAEAAAABAAAAAAAAAAgACAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==")!

    private func loadImage(_ name: String) -> UIImage {
        switch name {
        case "sample.png":
            return UIImage(data: Self.pngData)!
        case "multipage.tiff":
            return UIImage(data: Self.tiffData)!
        default:
            fatalError("Unknown image \(name)")
        }
    }

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
            case .success(let data):
                XCTAssertTrue(data.lines.contains { $0.contains("Total") })
                XCTAssertEqual(data.total, 5)
            case .failure(let error):
                XCTFail("Scan failed with error: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testMultiPageTiff() {
        let image = loadImage("multipage.tiff")
        XCTAssertEqual(image.size.width, 3)
        XCTAssertEqual(image.size.height, 3)
    }
}
#endif
