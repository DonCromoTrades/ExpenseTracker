// Common imports
import Foundation

public struct ReceiptData {
    public var total: Double?
    public var date: Date?
    public var vendor: String?
    public var lines: [String]
    public init(total: Double? = nil, date: Date? = nil, vendor: String? = nil, lines: [String]) {
        self.total = total
        self.date = date
        self.vendor = vendor
        self.lines = lines
    }
}

#if os(iOS)
import Vision
import UIKit

public class ReceiptScanner {
    public init() {}

    public func scan(image: UIImage, completion: @escaping (Result<ReceiptData, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(ScannerError.invalidImage))
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let texts = request.results?
                .compactMap { ($0 as? VNRecognizedTextObservation)?.topCandidates(1).first?.string } ?? []
            completion(.success(self.parseReceiptData(from: texts)))
        }
        request.recognitionLevel = .accurate
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation)
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func parseReceiptData(from lines: [String]) -> ReceiptData {
        var data = ReceiptData(lines: lines)
        data.vendor = lines.first?.trimmingCharacters(in: .whitespaces)

        let totalPattern = "(?i)total\\s*\\$?([0-9]+(?:\\.[0-9]{2})?)"
        for line in lines {
            if let match = line.range(of: totalPattern, options: .regularExpression) {
                if let amountRange = line.range(of: "[0-9]+(?:\\.[0-9]{2})?", options: .regularExpression, range: match) {
                    let amountStr = String(line[amountRange])
                    data.total = Double(amountStr)
                    break
                }
            }
        }

        let datePatterns = ["\\b\\d{1,2}/\\d{1,2}/\\d{2,4}\\b", "\\b\\d{4}-\\d{2}-\\d{2}\\b"]
        outer: for line in lines {
            for pattern in datePatterns {
                if let range = line.range(of: pattern, options: .regularExpression) {
                    let dateStr = String(line[range])
                    let fmts = ["MM/dd/yyyy", "MM/dd/yy", "yyyy-MM-dd", "dd/MM/yyyy", "dd/MM/yy"]
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    for f in fmts {
                        formatter.dateFormat = f
                        if let d = formatter.date(from: dateStr) {
                            data.date = d
                            break outer
                        }
                    }
                }
            }
        }
        return data
    }

    public enum ScannerError: Error {
        case invalidImage
    }
}

extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
#else
import Foundation

public class ReceiptScanner {
    public init() {}
    public func scan(imageData: Data, completion: @escaping (Result<ReceiptData, Error>) -> Void) {
        completion(.failure(ScannerError.unsupportedPlatform))
    }

    public enum ScannerError: Error {
        case unsupportedPlatform
    }
}
#endif
