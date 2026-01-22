//
//  MemorySessionData.swift
//  MemoryLane
//
//  Created by SDC-User on 17/12/25.
//

import Foundation
import UIKit

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
    var image: String?
    var textAnswers: [TextAnswer] = []
    var mcqAnswers: [MCQAnswer] = []
    
    var emotion: String?
    
    var selectedIdentificationAnswer: String? // Using this only for locking the answer, not useful for caregiver side
    
    var wasIdentifiedCorrectly: Bool?
    
    var timestamp: Date = Date()
}

struct MemoryImageSession {
    let imageId: String
    let image: UIImage

    var peopleShown: [String] = []              // All people in picture
    var personSessions: [MemorySessionData] = [] // Sessions per person

    var overallReflection: String? = nil        // Final answer for entire picture

    var timestamp: Date = Date()
}
