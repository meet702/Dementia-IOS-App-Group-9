//
//  DataStore.swift
//  IOS-App
//
//  Created by SDC-USER on 02/02/26.
//

import Foundation

// MARK: - App Data Store (Singleton)

final class AppDataStore {

    static let shared = AppDataStore()
    private init() {
        loadQuestions()
        loadDefaultPrompts()
    }

    // MARK: - Question Bank

    private(set) var mcqQuestions: [Question] = []
    private(set) var textQuestions: [Question] = []

    // MARK: - Memory Lane Prompts

    private(set) var memoryIntroPrompts: [String] = []
    private(set) var personIntroStatements: [String] = []
    private(set) var fallbackStatements: [String] = []
    private(set) var momentReflectionPrompts: [String] = []

    // MARK: - Loaders

    private func loadQuestions() {

        // MCQ Questions (low cognitive load)
        mcqQuestions = [
            Question(
                type: .mcq,
                prompt: "How does this person make you feel?",
                options: ["Calm", "Warm", "Happy", "Not sure"],
                positiveOptions: ["Calm", "Warm", "Happy"]
            ),
            Question(
                type: .mcq,
                prompt: "Did this person feel close to you?",
                options: ["Yes", "Somewhat", "Not Close", "Not sure"],
                positiveOptions: ["Yes", "Somewhat"]
            ),
            Question(
                type: .mcq,
                prompt: "Do you feel understood by this person?",
                options: ["Yes", "Sometimes", "Not really", "Not sure"],
                positiveOptions: ["Yes", "Sometimes"]
            ),
            Question(
                type: .mcq,
                prompt: "Does this person bring positive energy to your life?",
                options: ["Yes", "A little", "Not really", "Not sure"],
                positiveOptions: ["Yes", "A little"]
            ),
            Question(
                type: .mcq,
                prompt: "Do you enjoy spending time with this person?",
                options: ["Always", "Sometimes", "Rarely", "Not sure"],
                positiveOptions: ["Always", "Sometimes"]
            ),
            Question(
                type: .mcq,
                prompt: "Do you feel safe sharing things with this person?",
                options: ["Yes", "Mostly", "Not really", "Not sure"],
                positiveOptions: ["Yes", "Mostly"]
            ),
            Question(
                type: .mcq,
                prompt: "Does this person support you emotionally?",
                options: ["Yes", "Sometimes", "Not really", "Not sure"],
                positiveOptions: ["Yes", "Sometimes"]
            )
        ]


        // Text Questions (only if MCQ engagement is positive)
        textQuestions = [
            Question(
                type: .text,
                prompt: "What do you appreciate about this person?"
            ),
            Question(
                type: .text,
                prompt: "What stands out about this moment?"
            ),
            Question(
                type: .text,
                prompt: "Is there anything this person does that makes you feel valued?"
            ),
            Question(
                type: .text,
                prompt: "What memory with this person makes you smile?"
            ),
            Question(
                type: .text,
                prompt: "What makes this connection meaningful to you?"
            ),
            Question(
                type: .text,
                prompt: "How would you could describe this person in one sentence?"
            )
//            Question(
//                type: .text,
//                prompt: "What would you want to remember about this person years from now?"
//            )
        ]

    }

    private func loadDefaultPrompts() {

        // Spoken before caregiver audio / moment intro
        memoryIntroPrompts = [
            "Let’s take a moment with this memory.",
            "You can stay here as long as you like.",
            "Here’s a moment to revisit."
        ]

        // Shown before zooming into a person
        personIntroStatements = [
            "This person stands out in this moment.",
            "This person feels important here.",
            "Let’s take a closer look."
        ]

        // Used when patient skips / does not respond
        fallbackStatements = [
            "This person was part of this moment.",
            "You spent time looking at this person.",
            "This moment included people who felt familiar."
        ]

        // Whole image reflection (end of Memory Lane)
        momentReflectionPrompts = [
            "Does this feel like a special moment?",
            "How does this moment feel to you?",
            "Would you like to stay with this moment a bit longer?"
        ]
    }

    // MARK: - Public Helpers

    func randomMCQ() -> Question? {
        mcqQuestions.randomElement()
    }

    func randomTextQuestion() -> Question? {
        textQuestions.randomElement()
    }

    func randomPersonIntro() -> String {
        personIntroStatements.randomElement() ?? ""
    }

    func randomFallbackStatement() -> String {
        fallbackStatements.randomElement() ?? ""
    }

    func randomMomentPrompt() -> String {
        momentReflectionPrompts.randomElement() ?? ""
    }
}
