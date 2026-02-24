////
////  FaceDetectionService.swift
////  IOS-App
////
////  Created by SDC-USER on 04/02/26.
////
//
//import UIKit
//import Vision
//
///// Service to detect faces in images using Apple's Vision framework
//final class FaceDetectionServiceMemoryLane {
//    
//    // MARK: - Face Detection
//    
//    /// Detects faces in an image and returns Face objects sorted left to right
//    /// - Parameters:
//    ///   - image: The UIImage to detect faces in
//    ///   - imageID: The WholeImage ID to associate with the faces
//    ///   - completion: Returns array of Face objects sorted left→right, or error
//    static func detectFaces(
//        in image: UIImage,
//        imageID: UUID,
//        completion: @escaping (Result<[Face], Error>) -> Void
//    ) {
//        // Convert UIImage to CIImage
//        guard let ciImage = CIImage(image: image) else {
//            completion(.failure(FaceDetectionError.invalidImage))
//            return
//        }
//        
//        // Create face detection request
//        let request = VNDetectFaceRectanglesRequest { request, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            guard let observations = request.results as? [VNFaceObservation] else {
//                completion(.failure(FaceDetectionError.noFacesDetected))
//                return
//            }
//            
//            print("✅ Vision detected \(observations.count) faces")
//            
//            // Convert observations to Face objects
//            let faces = self.convertObservationsToFaces(
//                observations,
//                imageSize: image.size,
//                imageID: imageID
//            )
//            
//            completion(.success(faces))
//        }
//        
//        // Perform detection
//        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                try handler.perform([request])
//            } catch {
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    // MARK: - Conversion
//    
//    /// Converts Vision observations to Face objects
//    private static func convertObservationsToFaces(
//        _ observations: [VNFaceObservation],
//        imageSize: CGSize,
//        imageID: UUID
//    ) -> [Face] {
//        var faces: [Face] = []
//        
//        for (index, observation) in observations.enumerated() {
//            // Convert from Vision's normalized coordinates (0-1, bottom-left origin)
//            // to UIKit coordinates (pixels, top-left origin)
//            let boundingBox = convertVisionRectToUIKit(
//                observation.boundingBox,
//                imageSize: imageSize
//            )
//            
//            print("  Face \(index):")
//            print("    Vision normalized: \(observation.boundingBox)")
//            print("    UIKit pixels: \(boundingBox)")
//            
//            let face = Face(
//                fid: UUID(),
//                fileName: nil,  // Optional: Can crop and save face image later
//                boundingBox: boundingBox,
//                orderIndex: index,  // Temporary - will be sorted
//                imageID: imageID,
//                personID: nil       // Will be assigned during matching/labeling
//            )
//            
//            faces.append(face)
//        }
//        
//        // Sort faces left → right by bounding box center X
//        faces.sort { $0.boundingBox.midX < $1.boundingBox.midX }
//        
//        // Update orderIndex after sorting
//        for (index, _) in faces.enumerated() {
//            faces[index] = Face(
//                fid: faces[index].fid,
//                fileName: faces[index].fileName,
//                boundingBox: faces[index].boundingBox,
//                orderIndex: index,  // Now reflects left→right order
//                imageID: faces[index].imageID,
//                personID: faces[index].personID
//            )
//        }
//        
//        print("✅ Sorted \(faces.count) faces left → right")
//        
//        return faces
//    }
//    
//    /// Converts Vision's normalized rect (0-1, bottom-left origin)
//    /// to UIKit rect (pixels, top-left origin)
//    private static func convertVisionRectToUIKit(
//        _ visionRect: CGRect,
//        imageSize: CGSize
//    ) -> CGRect {
//        // Vision uses normalized coordinates (0.0 to 1.0)
//        // Vision uses bottom-left origin, UIKit uses top-left
//        
//        let x = visionRect.origin.x * imageSize.width
//        let width = visionRect.width * imageSize.width
//        let height = visionRect.height * imageSize.height
//        
//        // Flip Y coordinate (Vision: bottom-left, UIKit: top-left)
//        let y = imageSize.height - (visionRect.origin.y * imageSize.height) - height
//        
//        return CGRect(x: x, y: y, width: width, height: height)
//    }
//}
//
//// MARK: - Errors
//
//enum FaceDetectionError: LocalizedError {
//    case invalidImage
//    case noFacesDetected
//    
//    var errorDescription: String? {
//        switch self {
//        case .invalidImage:
//            return "Could not convert image for face detection"
//        case .noFacesDetected:
//            return "No faces detected in the image"
//        }
//    }
//}
