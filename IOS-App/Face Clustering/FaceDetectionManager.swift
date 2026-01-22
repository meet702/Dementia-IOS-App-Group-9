import UIKit
import Vision

final class FaceDetectionManager {

    static let shared = FaceDetectionManager()
    private init() {}
    
    struct DetectedFaceResult {
        let faceImage: UIImage
        let embedding: [Float]
        let boundingBox: CGRect
    }


    func detectFaces(in image: UIImage, completion: @escaping ([DetectedFaceResult]) -> Void) {
        let fixedImage = image.normalizedOrientation()

        guard let ciImage = CIImage(image: fixedImage) else {
            completion([])
            return
        }

        let request = VNDetectFaceRectanglesRequest { request, _ in
            guard let faces = request.results as? [VNFaceObservation],
                  !faces.isEmpty else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            var results: [DetectedFaceResult] = []
            
            for face in faces {
                guard let cropped = self.crop(face: face, from: fixedImage),
                    let embedding = FaceEmbedder.shared.embedding(from: cropped)
                else { continue }

                results.append(
                    DetectedFaceResult(
                        faceImage: cropped,
                        embedding: embedding,
                        boundingBox: face.boundingBox
                    )
                )
            }

            DispatchQueue.main.async {
                completion(results)
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }


    private func crop(face: VNFaceObservation, from image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let w = CGFloat(cgImage.width)
        let h = CGFloat(cgImage.height)

        var rect = CGRect(
            x: face.boundingBox.origin.x * w,
            y: (1 - face.boundingBox.origin.y - face.boundingBox.height) * h,
            width: face.boundingBox.width * w,
            height: face.boundingBox.height * h
        )

        rect = rect.insetBy(dx: -rect.width * 0.4, dy: -rect.height * 0.4)
        rect = rect.intersection(CGRect(x: 0, y: 0, width: w, height: h))

        guard let cropped = cgImage.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cropped)
    }
}
