import Foundation

#if canImport(UIKit)
import UIKit
import Vision

public class ReceiptCapture {
    public init() {}
    // Placeholder method to process a receipt image using Vision
    public func recognizeText(from image: UIImage, completion: @escaping (String?) -> Void) {
        let request = VNRecognizeTextRequest { request, _ in
            if let observations = request.results as? [VNRecognizedTextObservation] {
                let recognized = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: " ")
                completion(recognized)
            } else {
                completion(nil)
            }
        }
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        try? handler.perform([request])
    }
}
#else
/// Stub implementation used on platforms without UIKit/Vision (e.g. Linux).
/// The method signatures are simplified so the module can still be imported.
public class ReceiptCapture {
    public init() {}
    public func recognizeText(from imagePath: String, completion: @escaping (String?) -> Void) {
        completion(nil)
    }
}
#endif
