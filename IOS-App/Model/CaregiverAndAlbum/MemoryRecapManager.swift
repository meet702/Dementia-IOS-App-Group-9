//
//  MemoryRecapManager.swift
//  IOS-App
//
//  Created by SDC-USER on 04/03/26.
//

import Foundation

class MemoryRecapManager {

    static let shared = MemoryRecapManager()

    private var shuffledImageIDs: [UUID] = []
    private var currentIndex: Int = 0

    func nextImageID(from images: [WholeImage]) -> UUID? {

        // 🚫 No images available
        if images.isEmpty {
            return nil
        }

        // If shuffle list empty OR completed cycle → reshuffle
        if shuffledImageIDs.isEmpty || currentIndex >= shuffledImageIDs.count {

            shuffledImageIDs = images.map { $0.wid }.shuffled()
            currentIndex = 0
        }

        let id = shuffledImageIDs[currentIndex]
        currentIndex += 1
        return id
    }
}
