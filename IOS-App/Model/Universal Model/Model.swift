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

struct WholeImage: Identifiable, Codable {
    let wid: UUID

    let fileName: String
    let action: MemoryActionContent?
    let createdAt: Date
    var caregiverUid: UUID?

    var id: UUID { wid }
}

struct BoundingBox: Codable {
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat

    init(rect: CGRect) {
        self.x = rect.origin.x
        self.y = rect.origin.y
        self.width = rect.width
        self.height = rect.height
    }

    var cgRect: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }
}

struct Face: Identifiable, Codable {
    let fid: UUID
    let fileName: String
    let boundingBox: BoundingBox
    let orderIndex: Int
    var caregiverUid: UUID?

    let wid: UUID

    var personName: String?

    var id: UUID { fid }
}

struct ImageSession: Identifiable, Codable {
    let isid: UUID
    let wid: UUID
    let sessionType: SessionType

    let startedAt: Date
    var endedAt: Date?
    var recapCount: Int
    var caregiverUid: UUID?

    var id: UUID { isid }
}

enum SessionType: String, Codable {
    case memoryLane
    case memoryRecap
}

struct PersonSession: Identifiable, Codable {
    let psid: UUID
    let isid: UUID
    let fid: UUID
    var caregiverUid: UUID?

    var id: UUID { psid }
}

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

struct ImageSessionQuestion: Identifiable, Codable {
    let isqid: UUID
    let isid: UUID
    let qid: UUID
    var caregiverUid: UUID?

    let responseText: String?
    let selectedOption: String?
    let answeredAt: Date?

    var id: UUID { isqid }
}

struct PersonSessionQuestion: Identifiable, Codable {
    let psqid: UUID
    let psid: UUID
    let qid: UUID
    var caregiverUid: UUID?

    let responseText: String?
    let selectedOption: String?
    let answeredAt: Date?

    let wasPositive: Bool?

    var id: UUID { psqid }
}

struct ImageSessionComment: Identifiable, Codable {
    let icid: UUID
    let isid: UUID
    let commentText: String
    let createdBy: String?
    let createdAt: Date

    var id: UUID { icid }
}

struct UserProfile: Codable {
    let uid: UUID
    var name: String
    var email: String
    var role: UserRole
    var gender: String?
    var caregiverUid: UUID?
    var createdAt: Date?
    var caregiverRelation: String?
    var dob: String?

    enum UserRole: String, Codable {
        case caregiver
        case patient
    }
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

struct RoutineTask: Identifiable, Codable {
    let id: UUID
    var title: String
    var subtitle: String?
    var scheduledDate: Date?
    var time: Date
    var isRepeatDaily: Bool
    var completedDates: [Date]
    var isCompleted: Bool
    var caregiverUid: UUID?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case scheduledDate
        case time
        case isRepeatDaily
        case completedDates
        case isCompleted
        case caregiverUid
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(subtitle, forKey: .subtitle)

        if let scheduledDate = scheduledDate {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            df.timeZone = TimeZone.current
            try container.encode(df.string(from: scheduledDate), forKey: .scheduledDate)
        }

        try container.encode(isRepeatDaily, forKey: .isRepeatDaily)

        let cdf = DateFormatter()
        cdf.dateFormat = "yyyy-MM-dd"
        cdf.timeZone = TimeZone.current
        let completedStrings = completedDates.map { cdf.string(from: $0) }
        try container.encode(completedStrings, forKey: .completedDates)

        try container.encode(isCompleted, forKey: .isCompleted)

        let tf = DateFormatter()
        tf.dateFormat = "HH:mm:ss"
        let timeString = tf.string(from: time)
        try container.encode(timeString, forKey: .time)

        try container.encodeIfPresent(caregiverUid, forKey: .caregiverUid)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        isRepeatDaily = try container.decode(Bool.self, forKey: .isRepeatDaily)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        caregiverUid = try container.decodeIfPresent(UUID.self, forKey: .caregiverUid)

        if let dateString = try container.decodeIfPresent(String.self, forKey: .scheduledDate) {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            df.timeZone = TimeZone.current
            scheduledDate = df.date(from: dateString)
        } else {
            scheduledDate = nil
        }

        let timeString = try container.decode(String.self, forKey: .time)
        let tf = DateFormatter()
        tf.dateFormat = "HH:mm:ss"
        tf.timeZone = TimeZone.current
        if let parsedTime = tf.date(from: timeString) {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: Date())
            let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: parsedTime)
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
            components.second = timeComponents.second
            time = calendar.date(from: components) ?? parsedTime
        } else {
            time = Date()
        }

        let completedStrings = try container.decodeIfPresent([String].self, forKey: .completedDates) ?? []
        let utcDf = DateFormatter()
        utcDf.dateFormat = "yyyy-MM-dd"
        utcDf.timeZone = TimeZone(identifier: "UTC") ?? TimeZone.current
        completedDates = completedStrings.compactMap { utcDf.date(from: $0) }
    }

    init(
        id: UUID,
        title: String,
        subtitle: String? = nil,
        scheduledDate: Date? = nil,
        time: Date,
        isRepeatDaily: Bool,
        completedDates: [Date],
        isCompleted: Bool,
        caregiverUid: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.scheduledDate = scheduledDate
        self.time = time
        self.isRepeatDaily = isRepeatDaily
        self.completedDates = completedDates
        self.isCompleted = isCompleted
        self.caregiverUid = caregiverUid
    }
}
