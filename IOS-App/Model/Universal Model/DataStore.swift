//
//  DataStore.swift
//  IOS-App
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
    private(set) var reflectionQuestion: Question!

    // MARK: - Memory Lane Prompts

    private(set) var memoryIntroPrompts: [String] = []
    private(set) var personIntroStatements: [String] = []
    private(set) var fallbackStatements: [String] = []
    private(set) var momentReflectionPrompts: [String] = []

    // MARK: - Loaders

    private func loadQuestions() {

        // MARK: MCQ Questions (Stable UUIDs)

        mcqQuestions = [

            Question(
                qid: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
                type: .mcq,
                prompt: "How does this person make you feel?",
                options: ["Calm", "Warm", "Happy", "Not sure"],
                positiveOptions: ["Calm", "Warm", "Happy"]
            ),

            Question(
                qid: UUID(uuidString: "10000000-0000-0000-0000-000000000002")!,
                type: .mcq,
                prompt: "Did this person feel close to you?",
                options: ["Yes", "Somewhat", "Not Close", "Not sure"],
                positiveOptions: ["Yes", "Somewhat"]
            ),

            Question(
                qid: UUID(uuidString: "10000000-0000-0000-0000-000000000003")!,
                type: .mcq,
                prompt: "Do you feel understood by this person?",
                options: ["Yes", "Sometimes", "Not really", "Not sure"],
                positiveOptions: ["Yes", "Sometimes"]
            ),

            Question(
                qid: UUID(uuidString: "10000000-0000-0000-0000-000000000004")!,
                type: .mcq,
                prompt: "Does this person bring positive energy to your life?",
                options: ["Yes", "A little", "Not really", "Not sure"],
                positiveOptions: ["Yes", "A little"]
            ),

            Question(
                qid: UUID(uuidString: "10000000-0000-0000-0000-000000000005")!,
                type: .mcq,
                prompt: "Do you enjoy spending time with this person?",
                options: ["Always", "Sometimes", "Rarely", "Not sure"],
                positiveOptions: ["Always", "Sometimes"]
            ),

            Question(
                qid: UUID(uuidString: "10000000-0000-0000-0000-000000000006")!,
                type: .mcq,
                prompt: "Do you feel safe sharing things with this person?",
                options: ["Yes", "Mostly", "Not really", "Not sure"],
                positiveOptions: ["Yes", "Mostly"]
            ),

            Question(
                qid: UUID(uuidString: "10000000-0000-0000-0000-000000000007")!,
                type: .mcq,
                prompt: "Does this person support you emotionally?",
                options: ["Yes", "Sometimes", "Not really", "Not sure"],
                positiveOptions: ["Yes", "Sometimes"]
            )
        ]


        // MARK: Text Questions (Stable UUIDs)

        textQuestions = [

            Question(
                qid: UUID(uuidString: "20000000-0000-0000-0000-000000000001")!,
                type: .text,
                prompt: "What do you appreciate about this person?"
            ),

            Question(
                qid: UUID(uuidString: "20000000-0000-0000-0000-000000000002")!,
                type: .text,
                prompt: "What stands out about this moment?"
            ),

            Question(
                qid: UUID(uuidString: "20000000-0000-0000-0000-000000000003")!,
                type: .text,
                prompt: "Is there anything this person does that makes you feel valued?"
            ),

            Question(
                qid: UUID(uuidString: "20000000-0000-0000-0000-000000000004")!,
                type: .text,
                prompt: "What memory with this person makes you smile?"
            ),

            Question(
                qid: UUID(uuidString: "20000000-0000-0000-0000-000000000005")!,
                type: .text,
                prompt: "What makes this connection meaningful to you?"
            ),

            Question(
                qid: UUID(uuidString: "20000000-0000-0000-0000-000000000006")!,
                type: .text,
                prompt: "How would you describe this person in one sentence?"
            )
        ]

        // MARK: Reflection Question (Stable UUID)

        reflectionQuestion = Question(
            qid: UUID(uuidString: "30000000-0000-0000-0000-000000000001")!,
            type: .text,
            prompt: "What was happening in this moment?"
        )
    }

    private func loadDefaultPrompts() {

        memoryIntroPrompts = [
            "Let’s take a moment with this memory.",
            "You can stay here as long as you like.",
            "Here’s a moment to revisit."
        ]

        personIntroStatements = [
            "This person stands out in this moment.",
            "This person feels important here.",
            "Let’s take a closer look."
        ]

        fallbackStatements = [
            "This person was part of this moment.",
            "You spent time looking at this person.",
            "This moment included people who felt familiar."
        ]

        momentReflectionPrompts = [
            "Does this feel like a special moment?",
            "How does this moment feel to you?",
            "Would you like to stay with this moment a bit longer?"
        ]
    }
    
    func defaultQuestions() -> [Question] {
        var questions: [Question] = []
        if let mcq = mcqQuestions.randomElement() { questions.append(mcq) }
        if let text = textQuestions.randomElement() { questions.append(text) }
        return questions
    }

    // MARK: - Unified Lookup

    func question(for id: UUID) -> Question? {

        let allQuestions =
            mcqQuestions +
            textQuestions +
            [reflectionQuestion]

        return allQuestions.first { $0!.qid == id }!!
    }

    func prompt(for id: UUID) -> String {
        question(for: id)?.prompt ?? "Reflection"
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
