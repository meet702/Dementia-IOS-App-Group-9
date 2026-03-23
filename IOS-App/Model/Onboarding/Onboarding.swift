//
//  Onboarding.swift
//  IOS-App
//
//  Created by SDC-User on 02/02/26.
//

import Foundation

struct RoleModel {
    let title: String
    let subtitle: String
}
struct InputField {
    let title: String
    let placeholder: String
    let type: InputType
}

enum InputType {
    case text
    case phone
    case picker
}
