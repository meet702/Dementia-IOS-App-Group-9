//
//  CaregiverQuestions.swift
//  onboardingScreen
//
//  Created by SDC-USER on 16/12/25.
//

import Foundation

struct CaregiverQuestions {

    static func all() -> [OnboardingQuestions] {
        return [
            OnboardingQuestions(
                title: "1. How often do you interact with the patient?",
                options: [
                    "Daily (live together)",
                    "Few times a week (visits)",
                    "Weekly (remote)",
                    "Rarely"
                ],
                selectionType: .single
            ),

            OnboardingQuestions(
                title: "2. What kind of support do you provide?",
                options: [
                    "Daily",
                    "Few times a week",
                    "Weekly",
                    "Rarely"
                ],
                selectionType: .single
            ),

            OnboardingQuestions(
                title: "3. What is your main goal using this app?",
                options: [
                    "Monitor routines",
                    "Help with memory recall",
                    "Reduce patient anxiety",
                    "Stay connected",
                    "Track progress"
                ],
                selectionType: .multiple
            ),

            OnboardingQuestions(
                title: "4. Best time to receive updates?",
                options: [
                    "Morning",
                    "Afternoon",
                    "Evening"
                ],
                selectionType: .single
            ),
        ]
    }
}

