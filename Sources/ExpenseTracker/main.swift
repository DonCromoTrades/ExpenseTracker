import Foundation
import ReceiptScanner
#if canImport(UIKit)
import UIKit
#endif

let args = CommandLine.arguments
guard args.count > 1 else {
    print("Usage: ExpenseTracker <image-path>")
    exit(1)
}

let imagePath = args[1]

#if canImport(UIKit)
if let image = UIImage(contentsOfFile: imagePath) {
    let semaphore = DispatchSemaphore(value: 0)
    ReceiptScanner().scan(image: image) { result in
        switch result {
        case .success(let data):
            if let vendor = data.vendor { print("Vendor: \(vendor)") }
            if let total = data.total { print("Total: \(total)") }
            if let date = data.date { print("Date: \(date)") }
            print("Lines:")
            data.lines.forEach { print($0) }
        case .failure(let error):
            print("Scan failed: \(error)")
        }
        semaphore.signal()
    }
    semaphore.wait()
} else {
    print("Failed to load image at \(imagePath)")
    exit(1)
}
#else
let data = (try? Data(contentsOf: URL(fileURLWithPath: imagePath))) ?? Data()
let semaphore = DispatchSemaphore(value: 0)
ReceiptScanner().scan(imageData: data) { result in
    switch result {
    case .success(let data):
        print("Scanned \(data.lines.count) lines")
    case .failure(let error):
        print("Scan failed: \(error)")
    }
    semaphore.signal()
}
semaphore.wait()
#endif
