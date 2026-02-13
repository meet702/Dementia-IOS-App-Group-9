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
        let imageID = faces.first?.imageID
        allFaces.removeAll { $0.imageID == imageID }

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

        return allFaces.filter { $0.imageID == imageID }
    }

    // MARK: - Helpers

    private func fileURL() -> URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }
    
    func face(
        for personID: UUID,
        in imageID: UUID
    ) -> Face? {

        let faces = loadFaces(for: imageID)
        return faces.first { $0.personID == personID }
    }

}

