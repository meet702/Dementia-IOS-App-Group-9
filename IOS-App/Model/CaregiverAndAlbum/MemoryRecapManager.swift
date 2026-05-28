import Foundation

class MemoryRecapManager {

    static let shared = MemoryRecapManager()

    private var shuffledImageIDs: [UUID] = []
    private var currentIndex: Int = 0

    func nextImageID(from images: [WholeImage]) -> UUID? {

        if images.isEmpty {
            return nil
        }

        if shuffledImageIDs.isEmpty || currentIndex >= shuffledImageIDs.count {

            shuffledImageIDs = images.map { $0.wid }.shuffled()
            currentIndex = 0
        }

        let id = shuffledImageIDs[currentIndex]
        currentIndex += 1
        return id
    }
}
