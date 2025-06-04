#if os(iOS)
import Foundation
import Vision
import UIKit
import CoreImage

public class ReceiptScanner {
    public init() {}

    /// Detect the receipt region using Vision rectangles or crop using a manual rect.
    public func cropReceipt(in image: UIImage, rect: CGRect? = nil, completion: @escaping (UIImage?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }

        if let manual = rect {
            let scaled = CGRect(x: manual.origin.x * image.scale,
                                y: manual.origin.y * image.scale,
                                width: manual.width * image.scale,
                                height: manual.height * image.scale)
            if let cropped = cgImage.cropping(to: scaled) {
                completion(UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation))
            } else {
                completion(nil)
            }
            return
        }

        let request = VNDetectRectanglesRequest { req, _ in
            guard let rectObs = (req.results as? [VNRectangleObservation])?.first else {
                completion(nil)
                return
            }

            let width = CGFloat(cgImage.width)
            let height = CGFloat(cgImage.height)
            let bounding = rectObs.boundingBox
            let cropRect = CGRect(x: bounding.origin.x * width,
                                  y: (1 - bounding.origin.y - bounding.height) * height,
                                  width: bounding.width * width,
                                  height: bounding.height * height)
            if let cropped = cgImage.cropping(to: cropRect) {
                completion(UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation))
            } else {
                completion(nil)
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: CGImagePropertyOrientation(image.imageOrientation))
        DispatchQueue.global().async {
            try? handler.perform([request])
        }
    }

    private func preprocess(_ image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        let mono = ciImage.applyingFilter("CIPhotoEffectMono")
        let contrasted = mono.applyingFilter("CIColorControls", parameters: ["inputContrast": 1.5])
        let context = CIContext()
        if let cg = context.createCGImage(contrasted, from: contrasted.extent) {
            return UIImage(cgImage: cg, scale: image.scale, orientation: image.imageOrientation)
        }
        return image
    }

    public func scan(image: UIImage, cropRect: CGRect? = nil, preprocess: Bool = false, completion: @escaping (Result<[String], Error>) -> Void) {
        guard let _ = image.cgImage else {
            completion(.failure(ScannerError.invalidImage))
            return
        }

        let performScan: (UIImage) -> Void = { target in
            guard let cg = target.cgImage else {
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
            let orientation = CGImagePropertyOrientation(target.imageOrientation)
            let handler = VNImageRequestHandler(cgImage: cg, orientation: orientation)
            DispatchQueue.global().async {
                do {
                    try handler.perform([request])
                } catch {
                    completion(.failure(error))
                }
            }
        }

        let startingImage = preprocess ? self.preprocess(image) : image

        if cropRect != nil {
            cropReceipt(in: startingImage, rect: cropRect) { cropped in
                performScan(cropped ?? startingImage)
            }
        } else {
            performScan(startingImage)
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
    public func cropReceipt(in imageData: Data, rect: CGRect? = nil, completion: @escaping (Data?) -> Void) {
        completion(nil)
    }

    public func scan(imageData: Data, cropRect: CGRect? = nil, preprocess: Bool = false, completion: @escaping (Result<[String], Error>) -> Void) {
        completion(.failure(ScannerError.unsupportedPlatform))
    }

    public enum ScannerError: Error {
        case unsupportedPlatform
    }
}
#endif
