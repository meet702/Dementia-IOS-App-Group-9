// Question.swift
// Put this in Model (replace any other Question/Questions.swift)

import Foundation

enum QuestionType {
    case text
    case mcq
}

struct Question {
    let relation: String
    let type: QuestionType
    let question: String
    let options: [String]?
    let placeholder: String?    
}
