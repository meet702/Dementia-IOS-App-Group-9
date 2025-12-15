//
//  FaceDetectionManager.swift
//  IOS-App
//
//  Created by SDC-USER on 15/12/25.
//

import UIKit
import Vision
import CoreData

final class FaceDetectionManager {

    static let shared = FaceDetectionManager()
    private init() {}

    func detectFaces(
        in image: UIImage,
        completion: @escaping ([UIImage]) -> Void) {

        let fixedImage = image.normalizedOrientation()

        guard let cgImage = fixedImage.cgImage else {
            completion([])
            return
        }

        let request = VNDetectFaceRectanglesRequest { request, error in

            guard let observations = request.results as? [VNFaceObservation],
                  !observations.isEmpty else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }

            let faces = observations.compactMap {
                self.crop(face: $0, from: cgImage)
            }

            DispatchQueue.main.async {
                completion(faces)
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }


    // MARK: - Crop Face
    private func crop(face: VNFaceObservation, from image: CGImage) -> UIImage? {

        let imageWidth = CGFloat(image.width)
        let imageHeight = CGFloat(image.height)

        // Original bounding box (Vision coordinates → UIKit)
        var rect = CGRect(
            x: face.boundingBox.origin.x * imageWidth,
            y: (1 - face.boundingBox.origin.y - face.boundingBox.height) * imageHeight,
            width: face.boundingBox.width * imageWidth,
            height: face.boundingBox.height * imageHeight
        )

        // 🔹 Add padding
        let padding: CGFloat = 0.5
        let padX = rect.width * padding
        let padY = rect.height * padding

        rect = rect.insetBy(dx: -padX, dy: -padY)

        // 🔹 Clamp to image bounds
        rect.origin.x = max(0, rect.origin.x)
        rect.origin.y = max(0, rect.origin.y)

        if rect.maxX > imageWidth {
            rect.size.width = imageWidth - rect.origin.x
        }

        if rect.maxY > imageHeight {
            rect.size.height = imageHeight - rect.origin.y
        }

        guard let croppedCGImage = image.cropping(to: rect) else {
            return nil
        }

        return UIImage(cgImage: croppedCGImage)
    }

}

