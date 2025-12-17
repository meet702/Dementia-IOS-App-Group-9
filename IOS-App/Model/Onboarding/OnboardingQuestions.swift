//
//  Question.swift
//  onboardingScreen
//
//  Created by SDC-USER on 12/12/25.
//

import Foundation

struct OnboardingQuestions {
    let title: String
    let options: [String]
    let selectionType: SelectionType
    var selectedIndexes: Set<Int> = []
}

enum SelectionType {
    case single
    case multiple
}

