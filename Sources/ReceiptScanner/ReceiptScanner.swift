import Foundation
#if canImport(Vision)
import Vision
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(ImageIO)
import ImageIO
#endif

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

public class ReceiptScanner {
    public init() {}
}

#if canImport(Vision)
public extension ReceiptScanner {
    func scan(data: Data, completion: @escaping (Result<ReceiptData, Error>) -> Void) {
        let orientation = ReceiptScanner.exifOrientation(from: data)
        performScan(data: data, orientation: orientation, completion: completion)
    }

    #if canImport(UIKit)
    func scan(image: UIImage, completion: @escaping (Result<ReceiptData, Error>) -> Void) {
        guard let jpeg = image.jpegData(compressionQuality: 1.0) else {
            completion(.failure(ScannerError.invalidImage))
            return
        }
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        performScan(data: jpeg, orientation: orientation, completion: completion)
    }
    #endif
}
#endif

#if canImport(Vision)
private extension ReceiptScanner {
    func performScan(data: Data, orientation: CGImagePropertyOrientation, completion: @escaping (Result<ReceiptData, Error>) -> Void) {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
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
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation)
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
    }

    static func exifOrientation(from data: Data) -> CGImagePropertyOrientation {
        #if canImport(ImageIO)
        if let source = CGImageSourceCreateWithData(data as CFData, nil),
           let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
           let raw = props[kCGImagePropertyOrientation] as? UInt32,
           let orientation = CGImagePropertyOrientation(rawValue: raw) {
            return orientation
        }
        #endif
        return .up
    }

    func parseReceiptData(from lines: [String]) -> ReceiptData {
        var data = ReceiptData(lines: lines)
        data.vendor = lines.first?.trimmingCharacters(in: .whitespaces)

        let totalPattern = "(?i)total\\s*\\$?([0-9]+(?:\\.[0-9]{2})?)"
        for line in lines {
            if let match = line.range(of: totalPattern, options: .regularExpression),
               let amountRange = line.range(of: "[0-9]+(?:\\.[0-9]{2})?", options: .regularExpression, range: match) {
                let amountStr = String(line[amountRange])
                data.total = Double(amountStr)
                break
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
}
#endif

public enum ScannerError: Error {
    case invalidImage
    case unsupportedPlatform
}

#if !canImport(Vision)
public extension ReceiptScanner {
    func scan(data: Data, completion: @escaping (Result<ReceiptData, Error>) -> Void) {
        completion(.failure(ScannerError.unsupportedPlatform))
    }
}
#endif

#if canImport(UIKit)
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
#endif
