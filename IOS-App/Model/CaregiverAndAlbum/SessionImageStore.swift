//
//  SessionImageStore.swift
//  IOS-App
//

import UIKit

final class SessionImageStore {

    static let shared = SessionImageStore()
    private init() {}

    private let folderName = "SessionImages"

    // ✅ Copy image from LocalImageStore into SessionImages for permanent storage
    @discardableResult
    func saveSessionImage(for imageID: UUID) -> Bool {
        // Skip if already saved
        if fetchImage(by: imageID) != nil {
            print("⏭ Session image already saved for: \(imageID)")
            return true
        }

        guard let image = LocalImageStore.shared.fetchImage(by: imageID) else {
            print("❌ Could not find source image for session copy: \(imageID)")
            return false
        }

        let url = imageURL(for: imageID)

        guard let data = image.jpegData(compressionQuality: 0.9) else {
            return false
        }

        do {
            try data.write(to: url)
            print("✅ Session image saved permanently: \(imageID)")
            return true
        } catch {
            print("❌ Failed saving session image:", error)
            return false
        }
    }

    func fetchImage(by imageID: UUID) -> UIImage? {
        let url = imageURL(for: imageID)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    // MARK: - Paths

    private func imageURL(for imageID: UUID) -> URL {
        let folder = documentsDirectory().appendingPathComponent(folderName)
        try? FileManager.default.createDirectory(
            at: folder,
            withIntermediateDirectories: true
        )
        return folder.appendingPathComponent("\(imageID).jpg")
    }

    private func documentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
