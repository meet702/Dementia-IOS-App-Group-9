import Foundation
import UIKit

final class FaceStore {

    static let shared = FaceStore()
    private init() {}

    private let fileName = "faces.json"

    func saveFaces(_ faces: [Face]) {
        let url = fileURL()

        var allFaces: [Face] = []

        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([Face].self, from: data) {
            allFaces = decoded
        }

        let imageID = faces.first?.wid
        allFaces.removeAll { $0.wid == imageID }

        allFaces.append(contentsOf: faces)

        guard let data = try? JSONEncoder().encode(allFaces) else { return }
        try? data.write(to: url)
    }

    func loadFaces(for imageID: UUID) -> [Face] {
        let url = fileURL()

        guard
            let data = try? Data(contentsOf: url),
            let allFaces = try? JSONDecoder().decode([Face].self, from: data)
        else {
            return []
        }

        return allFaces
            .filter { $0.wid == imageID }
            .sorted { $0.orderIndex < $1.orderIndex }
    }

    private func fileURL() -> URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    func faceImage(for face: Face) -> UIImage? {
        let url = faceImageURL(for: face.fileName)
        return UIImage(contentsOfFile: url.path)
    }

    private func documentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func faceImageURL(for fileName: String) -> URL {
        let folder = documentsDirectory().appendingPathComponent("FaceImages")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent(fileName)
    }

    func deleteFaces(for imageID: UUID) {
        let url = fileURL()

        guard let data = try? Data(contentsOf: url),
              var allFaces = try? JSONDecoder().decode([Face].self, from: data)
        else { return }

        allFaces.removeAll { $0.wid == imageID }

        guard let newData = try? JSONEncoder().encode(allFaces) else { return }
        try? newData.write(to: url)

    }
    func clearAll() {

        try? FileManager.default.removeItem(at: fileURL())

        let faceImagesFolder = documentsDirectory()
            .appendingPathComponent("FaceImages")
        try? FileManager.default.removeItem(at: faceImagesFolder)

    }

    func loadAllFaces() -> [Face] {
        let url = fileURL()
        guard let data = try? Data(contentsOf: url),
              let faces = try? JSONDecoder().decode([Face].self, from: data)
        else { return [] }
        return faces
    }

}
