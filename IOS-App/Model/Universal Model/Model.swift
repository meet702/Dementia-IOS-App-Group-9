import Foundation
import CoreGraphics

// MARK: - Whole Image (Memory Anchor)

struct WholeImage: Identifiable, Codable {
    let wid: UUID
    let imageURL: URL
    let audioDescriptionURL: URL?
    let createdAt: Date

    // SwiftUI identity (UI concern)
    var id: UUID { wid }
}

// MARK: - Person (Identity within a memory)

struct Person: Identifiable, Codable, Equatable {
    let pid: UUID
    var name: String?
    var relationLabel: String?

    var id: UUID { pid }
}

// MARK: - Face (Visual instance in a specific image)

struct Face: Identifiable, Codable {
    let fid: UUID
    let faceImageURL: URL?
    let boundingBox: CGRect
    let orderIndex: Int

    // ID references (NOT foreign keys)
    let imageID: UUID          // refers to WholeImage.wid
    let personID: UUID?        // refers to Person.pid (optional)

    var id: UUID { fid }
}

// MARK: - Image Session (One playback / visit of a memory)

struct ImageSession: Identifiable, Codable {
    let isid: UUID
    let imageID: UUID
    let sessionType: SessionType
    let playedBy: String?
    let startedAt: Date
    var endedAt: Date?

    var id: UUID { isid }
}

enum SessionType: String, Codable {
    case memoryLane
    case memoryRecap
}

// MARK: - Person Session (Per-person interaction within a session)

struct PersonSession: Identifiable, Codable {
    let psid: UUID
    let imageSessionID: UUID
    let personID: UUID

    var id: UUID { psid }
}

// MARK: - Question Bank (App-provided)

struct Question: Identifiable, Codable {
    let qid: UUID
    let type: QuestionType
    let prompt: String
    let options: [String]?

    var id: UUID { qid }

    init(
        qid: UUID = UUID(),
        type: QuestionType,
        prompt: String,
        options: [String]? = nil
    ) {
        self.qid = qid
        self.type = type
        self.prompt = prompt
        self.options = options
    }
}


enum QuestionType: String, Codable {
    case mcq
    case text
}

// MARK: - Image Session Question (Whole-moment responses)

struct ImageSessionQuestion: Identifiable, Codable {
    let isqid: UUID
    let imageSessionID: UUID
    let questionID: UUID

    let responseText: String?
    let selectedOption: String?
    let answeredAt: Date?
    let confidenceScore: Double?

    var id: UUID { isqid }
}

// MARK: - Person Session Question (Per-person responses)

struct PersonSessionQuestion: Identifiable, Codable {
    let psqid: UUID
    let personSessionID: UUID
    let questionID: UUID

    let responseText: String?
    let selectedOption: String?
    let answeredAt: Date?
    let confidenceScore: Double?

    var id: UUID { psqid }
}

// MARK: - Image Session Comment (Caregiver reflections)

struct ImageSessionComment: Identifiable, Codable {
    let icid: UUID
    let imageSessionID: UUID
    let commentText: String
    let createdBy: String?
    let createdAt: Date

    var id: UUID { icid }
}
