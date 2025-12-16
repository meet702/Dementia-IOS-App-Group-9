import UIKit

struct MemoryImageSession {
    let imageId: String
    let image: UIImage

    var peopleShown: [String] = []              // All people in picture
    var personSessions: [MemorySessionData] = [] // Sessions per person

    var overallReflection: String? = nil        // Final answer for entire picture

    var timestamp: Date = Date()
}
