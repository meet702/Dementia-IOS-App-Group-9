import Foundation
import CoreGraphics

enum MemoryActionContent: Codable {
    case empty
    case text(String)
    case voice(URL)

    enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    enum ActionType: String, Codable {
        case empty
        case text
        case voice
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .empty:
            try container.encode(ActionType.empty, forKey: .type)

        case .text(let text):
            try container.encode(ActionType.text, forKey: .type)
            try container.encode(text, forKey: .value)

        case .voice(let url):
            try container.encode(ActionType.voice, forKey: .type)
            try container.encode(url, forKey: .value)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ActionType.self, forKey: .type)

        switch type {
        case .empty:
            self = .empty

        case .text:
            let text = try container.decode(String.self, forKey: .value)
            self = .text(text)

        case .voice:
            let url = try container.decode(URL.self, forKey: .value)
            self = .voice(url)
        }
    }
}
// MARK: - Whole Image (Memory Anchor)

struct WholeImage: Identifiable, Codable {
    let wid: UUID
    //let imageURL: URL
    let fileName: String                     // storing filename instead of url to persist image upon rerun
    let action: MemoryActionContent?
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
    //let faceImageURL: URL?
    let fileName: String     // storing filename instead of url to persist image upon rerun
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
//    let playedBy: String?
    let startedAt: Date
    var endedAt: Date?
    var recapCount: Int

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
    let positiveOptions: [String]?
    var id: UUID { qid }

    init(
        qid: UUID = UUID(),
        type: QuestionType,
        prompt: String,
        options: [String]? = nil,
        positiveOptions: [String]? = nil
    ) {
        self.qid = qid
        self.type = type
        self.prompt = prompt
        self.options = options
        self.positiveOptions = positiveOptions
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
    
    let wasPositive: Bool?          // ⭐ ADD THIS ****NEW****
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

extension PersonSessionQuestion {
    
    var recapSummaryText: String {
        
        if let selected = selectedOption {
            let lower = selected.lowercased()
            
            switch lower {
                
            case "calm":
                return "This person made you feel calm."
                
            case "warm":
                return "This person made you feel warm."
                
            case "happy":
                return "This person made you feel happy."
                
            case "yes":
                return "You felt close to this person."
                
            case "somewhat":
                return "You felt somewhat close to this person."
                
            case "not close":
                return "You didn't feel very close to them."
                
            case "sometimes":
                return "You sometimes felt understood by them."
                
            case "not really":
                return "You didn't always feel understood."
                
            case "always":
                return "You always enjoyed spending time together."
                
            case "rarely":
                return "You rarely spent time together."
                
            case "a little":
                return "This person brought positive energy to your life."
                
            case "mostly":
                return "You mostly felt safe sharing with them."
                
            case "not sure":
                return "You weren't quite sure how you felt."
                
            default:
                return "You felt \(lower) about this person."
            }
        }
        
        if let text = responseText, !text.isEmpty {
            return "\"\(text)\""
        }
        
        return ""
    }
    
    var hasContent: Bool {
        if selectedOption != nil { return true }
        if let text = responseText, !text.isEmpty { return true }
        return false
    }
}
