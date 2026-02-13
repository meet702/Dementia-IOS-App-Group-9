//
//  LocalImageStore.swift
//  IOS-App
//
//  Created by SDC-USER on 02/02/26.
//

import Foundation
import UIKit
final class LocalImageStore {

    static let shared = LocalImageStore()
    private init() {}

    private let folderName = "AlbumImages"

    func saveImage(_ image: UIImage) -> WholeImage {
        let wid = UUID()
        let fileURL = imageURL(for: wid)

        if let data = image.jpegData(compressionQuality: 0.9) {
            try? data.write(to: fileURL)
        }

        let wholeImage = WholeImage(
            wid: wid,
            imageURL: fileURL,
            action: .empty,
            createdAt: Date()
        )

        persist(wholeImage)
        print("📁 Image saved at:", fileURL)
        print("📄 Metadata at:", metadataURL())

        return wholeImage
        
        
    }

    func fetchAllImages() -> [WholeImage] {
        loadPersistedImages()
    }
    
    func fetchImage(by id: UUID) -> UIImage? {
        let url = imageURL(for: id)
        return UIImage(contentsOfFile: url.path)
    }
    func fetchImageModel(by id: UUID) -> WholeImage? {
        loadPersistedImages().first { $0.wid == id }
    }

    
    func deleteImage(_ image: WholeImage) {
        try? FileManager.default.removeItem(at: image.imageURL)

        var all = loadPersistedImages()
        all.removeAll { $0.wid == image.wid }

        if let data = try? JSONEncoder().encode(all) {
            try? data.write(to: metadataURL())
        }
    }


    // MARK: - Persistence

    private func persist(_ image: WholeImage) {
        var all = loadPersistedImages()
        all.append(image)

        let url = metadataURL()
        if let data = try? JSONEncoder().encode(all) {
            try? data.write(to: url)
        }
    }

    private func loadPersistedImages() -> [WholeImage] {
        let url = metadataURL()
        guard let data = try? Data(contentsOf: url),
              let images = try? JSONDecoder().decode([WholeImage].self, from: data)
        else { return [] }
        print("📦 Loading metadata from:", metadataURL())


        return images
    }

    // MARK: - Paths

    private func imageURL(for id: UUID) -> URL {
        let folder = documentsDirectory().appendingPathComponent(folderName)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("\(id).jpg")
    }

    private func metadataURL() -> URL {
        documentsDirectory().appendingPathComponent("album_metadata.json")
    }

    private func documentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func update(_ updatedImage: WholeImage) {

        var all = loadPersistedImages()

        if let index = all.firstIndex(where: { $0.wid == updatedImage.wid }) {
            all[index] = updatedImage
        } else {
            all.append(updatedImage)
        }

        if let data = try? JSONEncoder().encode(all) {
            try? data.write(to: metadataURL())
        }
    }

}
