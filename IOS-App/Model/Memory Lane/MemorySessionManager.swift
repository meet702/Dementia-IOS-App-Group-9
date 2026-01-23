import Foundation
import UIKit

class MemorySessionManager {

    static let shared = MemorySessionManager()
    private init() {}

    // Session State
    var sessionInProgress: Bool = false

    enum SessionStep {
        case pictureIntro
        case identifyPerson
        case text
        case mcq
        case emotion
        case finalQuestion
        case completed
    }

    var lastStep: SessionStep = .pictureIntro

    var currentSession: PersonSession?
    var currentImageSession: MemoryImageSession?
    var completedImageSessions: [MemoryImageSession] = []

    private(set) var totalSteps: Int = 0
    private(set) var currentStep: Int = 0

    private let stepsPerPerson = 6
    private let finalImageStep = 1

    // Session Lifecycle
    func startImageSession(image: String, peopleShown: [String]) {

        currentImageSession = MemoryImageSession(
//            imageId: UUID().uuidString,
            image: image,
            peopleShown: peopleShown,
            personSessions: [],
            overallReflection: nil,
            timestamp: Date()
        )

        totalSteps = (peopleShown.count * stepsPerPerson) + finalImageStep
        currentStep = 0

        print("Image session started")
        print("People:", peopleShown.count)
        print("Total steps:", totalSteps)
    }

    func beginSession(for person: String, relation: String, image: String) {
        sessionInProgress = true
        lastStep = .identifyPerson

        currentSession = PersonSession(
            personName: person,
            relation: relation,
            image: image,
            textAnswers: [],
            mcqAnswers: [],
            emotion: nil,
            wasIdentifiedCorrectly: nil,
            timestamp: Date()
        )
    }

    // Answer Recording
    func setIdentificationResult(correct: Bool) {
        currentSession?.wasIdentifiedCorrectly = correct
    }

    func addTextAnswer(question: Question, answer: String) {
        currentSession?.textAnswers.append(
            TextAnswer(question: question.question, answer: answer, symbol: question.symbol)
        )
    }

    func addMCQAnswer(question: Question, selected: [String]) {
        currentSession?.mcqAnswers.append(
            MCQAnswer(question: question.question, selectedOption: selected, symbol: question.symbol)
        )
    }

    func setEmotion(_ emotion: String) {
        currentSession?.emotion = emotion
    }

    // Completion
    func completeSession() {
        guard let personSession = currentSession else { return }

        print("----- PERSON SESSION COMPLETED -----")
        print("Person Name:", personSession.personName)
        print("Relation:", personSession.relation)

        if let identified = personSession.wasIdentifiedCorrectly {
            print("Identified Correctly:", identified)
        }

        print("\n--- MCQ Answers ---")
        for mcq in personSession.mcqAnswers {
            print("Question:", mcq.question)
            print("Selected Option:", mcq.selectedOption)
            print("------------------")
        }

        print("\n--- Text Answers ---")
        for text in personSession.textAnswers {
            print("Question:", text.question)
            print("Answer:", text.answer)
            print("------------------")
        }
        if let emotion = personSession.emotion {
            print("Emotion:", emotion)
        }
        print("----- END SESSION -----\n")
        currentImageSession?.personSessions.append(personSession)

        currentSession = nil
        sessionInProgress = false
        lastStep = .completed
    }

    func finishImageSession(overallReflection: String?) {
        currentImageSession?.overallReflection = overallReflection

        if let finished = currentImageSession {
            completedImageSessions.append(finished)
        }

        currentImageSession = nil
    }

    // Progress API
    func advanceProgress() -> Float {
        guard totalSteps > 0 else { return 0 }

        currentStep = min(currentStep + 1, totalSteps)

        print("Progress:", currentStep, "/", totalSteps)

        return Float(currentStep) / Float(totalSteps)
    }

    func currentProgress() -> Float {
        guard totalSteps > 0 else { return 0 }
        return Float(currentStep) / Float(totalSteps)
    }
}
