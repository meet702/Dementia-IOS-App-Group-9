//
//  MemorySessionData.swift
//  MemoryLane
//
//  Created by SDC-User on 17/12/25.
//

import Foundation
import UIKit

struct PersonData {
    var name: String
    var summary: String
    var hint: String
    var personImage: String
}

struct TextAnswer {
    let question: String
    let answer: String
    let symbol: String?
}

struct MCQAnswer {
    let question: String
    let selectedOption: [String]
    let symbol: String?
}

struct PersonSession {
    var personName: String
    var relation: String
    var image: String
    var textAnswers: [TextAnswer] = []
    var mcqAnswers: [MCQAnswer] = []
    
    var emotion: String?
    
    var selectedIdentificationAnswer: String? // Using this only for locking the answer, not useful for caregiver side
    
    var wasIdentifiedCorrectly: Bool?
    
    var timestamp: Date = Date()
}

struct MemoryImageSession {
//    let imageId: String
    let image: String

    var peopleShown: [String] = []              // All people in picture
    var personSessions: [PersonSession] = [] // Sessions per person

    var overallReflection: String? = nil        // Final answer for entire picture

    var timestamp: Date = Date()
}

enum ResponseRow {
    case text(question: String, answer: String, symbol: String)
}

extension PersonSession {

    func buildResponseRows() -> [ResponseRow] {
        var rows: [ResponseRow] = []

        if let emotion {
            rows.append(
                .text(
                    question: "Associated Emotion",
                    answer: emotion,
                    symbol: "smiley"
                )
            )
        }

        for mcq in mcqAnswers {
            let combinedOptions = mcq.selectedOption
                .map { "\($0)" }
                .joined(separator: "\n")

            rows.append(
                .text(
                    question: mcq.question,
                    answer: combinedOptions,
                    symbol: mcq.symbol ?? ""
                )
            )
        }
        for text in textAnswers {
            rows.append(
                .text(
                    question: text.question,
                    answer: text.answer,
                    symbol: text.symbol ?? ""
                )
            )
        }

        return rows
    }
}
