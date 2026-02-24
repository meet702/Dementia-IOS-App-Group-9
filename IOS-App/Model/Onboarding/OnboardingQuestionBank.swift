//
//  OnboardingQuestionBank.swift
//  IOS-App
//
//  Created by SDC-User on 02/02/26.
//

import Foundation

enum OnboardingQuestionBank {


    static let patientHeaders = [
        "Daily independence",
        "Hearing & vision",
        "Activities you enjoy",
        "Support system",
        "Device comfort"
    ]

    static func patientQuestions() -> [OnboardingQuestion] {
        return [
            OnboardingQuestion(
                title: "Do you need help with everyday tasks (meds, phone, shopping)?",
                options: ["No help", "Some help", "Need a lot of help"],
                selectionType: .single
            ),

            OnboardingQuestion(
                title: "Do you have hearing or vision problems that make it harder to use phones or talk?",
                options: ["No", "Sometimes", "Yes"],
                selectionType: .single
            ),

            OnboardingQuestion(
                title: "Which activities do you enjoy? (pick all that apply)",
                options: [
                    "Looking at photos",
                    "Word/memory games",
                    "Puzzles/brain games",
                    "Short audio stories",
                    "Daily reminders"
                ],
                selectionType: .multiple
            ),

            OnboardingQuestion(
                title: "Do you have someone who helps with daily care?",
                options: ["No, I live alone", "Family helps", "Professional caregiver"],
                selectionType: .single
            ),

            OnboardingQuestion(
                title: "How comfortable are you using a smartphone or tablet?",
                options: ["Very comfortable", "Somewhat comfortable", "Not comfortable"],
                selectionType: .single
            )
        ]
    }


    static let caregiverHeaders = [
        "Your involvement",
        "Your support type",
        "Your main goal",
        "Update preference"
    ]

    static func caregiverQuestions() -> [OnboardingQuestion] {
        return [
            OnboardingQuestion(
                title: "How often do you interact with the patient?",
                options: ["Daily", "Few times a week", "Weekly", "Rarely"],
                selectionType: .single
            ),

            OnboardingQuestion(
                //title: "What kind of support do you provide?",
                title: "How frequently do you provide support?",
                options: ["Daily", "Few times a week", "Weekly", "Rarely"],
                selectionType: .single
            ),

            OnboardingQuestion(
                title: "What is your main goal using this app?",
                options: [
                    "Monitor routines",
                    "Help with memory recall",
                    "Reduce patient anxiety",
                    "Stay connected",
                    "Track progress"
                ],
                selectionType: .multiple
            ),

            OnboardingQuestion(
                title: "Best time to receive updates?",
                options: ["Morning", "Afternoon", "Evening"],
                selectionType: .single
            )
        ]
    }
}
