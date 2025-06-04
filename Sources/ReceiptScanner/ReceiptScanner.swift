#if os(iOS)
import Foundation
import Vision
import UIKit

public class ReceiptScanner {
    public init() {}

    public func scan(image: UIImage, completion: @escaping (Result<[String], Error>) -> Void) {
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
            completion(.success(texts))
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
    public func scan(imageData: Data, completion: @escaping (Result<[String], Error>) -> Void) {
        completion(.failure(ScannerError.unsupportedPlatform))
    }

    public enum ScannerError: Error {
        case unsupportedPlatform
    }
}
#endif
