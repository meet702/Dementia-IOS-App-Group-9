//
//  FaceDetectionService.swift
//  IOS-App
//
//  Created by SDC-USER on 04/02/26.
//


import UIKit
import Vision
import CoreGraphics
import ImageIO

final class FaceDetectionService {

    // MARK: - Public API

    func detectFaces(
        in image: UIImage,
        imageID: UUID,
        completion: @escaping ([Face]) -> Void
    ) {

        guard let cgImage = image.cgImage else {
            print("image.cgImage is nil")
            completion([])
            return
        }

        let request = VNDetectFaceRectanglesRequest { [weak self] request, error in

            if let error = error {
                print("Vision error:", error)
                DispatchQueue.main.async { completion([]) }
                return
            }

            guard
                let self = self,
                let observations = request.results as? [VNFaceObservation]
            else {
                DispatchQueue.main.async { completion([]) }
                return
            }

            print("Vision observations count:", observations.count)

            let imageSize = CGSize(width: cgImage.width, height: cgImage.height)

            let rects = observations.map { obs -> CGRect in
                var rect = CGRect(
                    x: obs.boundingBox.origin.x * imageSize.width,
                    y: (1 - obs.boundingBox.origin.y - obs.boundingBox.height) * imageSize.height,
                    width: obs.boundingBox.width * imageSize.width,
                    height: obs.boundingBox.height * imageSize.height
                )

                rect = rect.insetBy(dx: -rect.width * 0.4, dy: -rect.height * 0.4)
                rect = rect.intersection(CGRect(origin: .zero, size: imageSize))
                return rect
            }

            let sorted = rects.sorted { $0.minX < $1.minX }

            let faces: [Face] = sorted.enumerated().compactMap { index, rect in
                guard let cropped = cgImage.cropping(to: rect) else { return nil }
                let uiImage = UIImage(cgImage: cropped)
                let url = self.saveFaceImage(uiImage)

                return Face(
                    fid: UUID(),
                    faceImageURL: url,
                    boundingBox: rect,
                    orderIndex: index,
                    imageID: imageID,
                    personID: nil
                )
            }

            DispatchQueue.main.async {
                completion(faces)
            }
        }

        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: CGImagePropertyOrientation(image.imageOrientation),
            options: [:]
        )

        do {
            try handler.perform([request])
            print("Vision perform finished")
        } catch {
            print("Vision perform error:", error)
            completion([])
        }

    }


    
    func convertBoundingBox(
        _ boundingBox: CGRect,
        imageSize: CGSize
    ) -> CGRect {
        let x = boundingBox.origin.x * imageSize.width
        let width = boundingBox.size.width * imageSize.width

        let height = boundingBox.size.height * imageSize.height
        let y = (1 - boundingBox.origin.y - boundingBox.size.height)
                * imageSize.height

        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func crop(image: UIImage, rect: CGRect) -> UIImage? {
        guard
            let cgImage = image.cgImage,
            let cropped = cgImage.cropping(to: rect)
        else {
            return nil
        }

        return UIImage(cgImage: cropped)
    }
    
    func saveFaceImage(_ image: UIImage) -> URL? {
        let filename = UUID().uuidString + ".jpg"
        let directory = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]

        let url = directory.appendingPathComponent(filename)

        guard let data = image.jpegData(compressionQuality: 0.9) else {
            return nil
        }

        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }
}


extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default:
            self = .up
        }
    }
}

extension UIImage {

    func renderedCGImage() -> CGImage? {
        guard let ciImage = CIImage(image: self) else { return nil }

        let context = CIContext(options: nil)
        return context.createCGImage(ciImage, from: ciImage.extent)
    }
}



