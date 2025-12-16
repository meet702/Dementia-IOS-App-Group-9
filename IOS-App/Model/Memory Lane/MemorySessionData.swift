import Foundation

struct TextAnswer {
    let question: String
    let answer: String
}

struct MCQAnswer {
    let question: String
    let selectedOption: String
}

struct MemorySessionData {
    var personName: String
    var relation: String

    var textAnswers: [TextAnswer] = []
    var mcqAnswers: [MCQAnswer] = []
    
    var emotion: String?
    var finalReflection: String?
    
    var wasIdentifiedCorrectly: Bool?
    
    var timestamp: Date = Date()
}

