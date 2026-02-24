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
        let fileName = "\(wid).jpg"
        let fileURL = imageURL(forFileName: fileName)

        if let data = image.jpegData(compressionQuality: 0.9) {
            try? data.write(to: fileURL)
        }

        let wholeImage = WholeImage(
            wid: wid,
            fileName: fileName,
            action: .empty,
            createdAt: Date()
        )

        persist(wholeImage)
//        print("📁 Image saved at:", fileURL)
//        print("📄 Metadata at:", metadataURL())

        return wholeImage
        
        
    }

    func fetchAllImages() -> [WholeImage] {
        loadPersistedImages()
    }
    
    func fetchImage(by id: UUID) -> UIImage? {

        guard let model = fetchImageModel(by: id) else { return nil }

        let url = imageURL(forFileName: model.fileName)

        return UIImage(contentsOfFile: url.path)
    }
    
    func fetchImageModel(by id: UUID) -> WholeImage? {
        loadPersistedImages().first { $0.wid == id }
    }

    
    func deleteImage(_ image: WholeImage) {

        let fileURL = imageURL(forFileName: image.fileName)
        try? FileManager.default.removeItem(at: fileURL)

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
        print("📦 Loaded WholeImages:", images.count)


        return images
    }

    // MARK: - Paths

    private func imageURL(forFileName fileName: String) -> URL {
        let folder = documentsDirectory().appendingPathComponent(folderName)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent(fileName)
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
    
    func fileURL(for image: WholeImage) -> URL {
        imageURL(forFileName: image.fileName)
    }

    func fileExists(for image: WholeImage) -> Bool {
        let url = imageURL(forFileName: image.fileName)
        return FileManager.default.fileExists(atPath: url.path)
    }
    

}
