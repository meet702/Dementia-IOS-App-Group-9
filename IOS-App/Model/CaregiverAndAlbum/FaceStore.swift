//
//  FaceStore.swift
//  IOS-App
//
//  Created by SDC-USER on 02/02/26.
//

import Foundation
import UIKit


final class FaceStore {

    static let shared = FaceStore()
    private init() {}

    private let fileName = "faces.json"

    // MARK: - Public API

    func saveFaces(_ faces: [Face]) {
        let url = fileURL()

        // 1️⃣ Load existing faces
        var allFaces: [Face] = []

        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([Face].self, from: data) {
            allFaces = decoded
        }

        // 2️⃣ Remove old faces for this image
        let imageID = faces.first?.wid
        allFaces.removeAll { $0.wid == imageID }

        // 3️⃣ Append updated faces
        allFaces.append(contentsOf: faces)

        // 4️⃣ Save merged result
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
            .sorted { $0.orderIndex < $1.orderIndex } // ✅ always sorted by orderIndex
    }

    // MARK: - Helpers

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

        print("🗑 Faces deleted for imageID: \(imageID)")
    }
    func clearAll() {
        // Delete JSON metadata
        try? FileManager.default.removeItem(at: fileURL())
        
        // ✅ Also delete all face image files
        let faceImagesFolder = documentsDirectory()
            .appendingPathComponent("FaceImages")
        try? FileManager.default.removeItem(at: faceImagesFolder)
        
        print("🧹 FaceStore cleared")
    }
    
    func loadAllFaces() -> [Face] {
        let url = fileURL()
        guard let data = try? Data(contentsOf: url),
              let faces = try? JSONDecoder().decode([Face].self, from: data)
        else { return [] }
        return faces
    }

}

