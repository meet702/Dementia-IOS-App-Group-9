//
//  CaregiverInputField.swift
//  onboardingScreen
//
//  Created by SDC-USER on 16/12/25.
//

import Foundation

enum InputType {
    case text
    case phone
    case picker
}

struct CaregiverInputField {
    let title: String
    let placeholder: String
    let type: InputType
}
