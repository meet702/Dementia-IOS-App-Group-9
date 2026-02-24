//
//  OnboardingProfiles.swift
//  IOS-App
//
//  Created by SDC-User on 02/02/26.
//

import Foundation



struct QuestionAnswer: Codable {
    let questionTitle: String
    let selectedOptions: [String]
}



struct PatientOnboardingProfile: Codable {

    // Basic Info
    let fullName: String
    let dateOfBirth: Date?
    let gender: String

    // MCQ Answers
    let answers: [QuestionAnswer]

    // Metadata
    let createdAt: Date
}


struct CaregiverOnboardingProfile: Codable {

    let fullName: String
    let phoneNumber: String
    let address: String
    let relationshipToPatient: String
    let gender: String

    // MCQ Answers
    let answers: [QuestionAnswer]

    // Extra Inputs
    let freeTextResponse: String?
    let connectionCode: String?

    // Metadata
    let createdAt: Date
}
