//
//  Untitled.swift
//  IOS-App
//
//  Created by SDC-USER on 15/12/25.
//

import UIKit

final class ImageStorageManager {

    static let shared = ImageStorageManager()
    private init() {}

    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func saveImage(_ image: UIImage) -> String? {
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = documentsURL.appendingPathComponent(fileName)

        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }

        try? data.write(to: fileURL)
        return fileName
    }

    func loadImage(from fileName: String) -> UIImage? {
        let fileURL = documentsURL.appendingPathComponent(fileName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func deleteImage(named fileName: String) {
        let url = documentsURL.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: url)
    }

}
