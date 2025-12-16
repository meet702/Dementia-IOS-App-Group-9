import Foundation
import UIKit

class MemorySessionManager {

    static let shared = MemorySessionManager()
    private init() {}

    var sessionInProgress: Bool = false

    enum SessionStep {
        case pictureIntro
        case identifyPerson
        case followup
        case finalQuestion
        case completed
    }

    var lastStep: SessionStep = .pictureIntro

    var currentSession: MemorySessionData?
    var currentImageSession: MemoryImageSession?
    var completedImageSessions: [MemoryImageSession] = []

    private(set) var totalSteps: Int = 0
    private(set) var currentStep: Int = 0

    let stepsPerPerson: Int = 2


    func startImageSession(image: UIImage, peopleShown: [String]) {

        currentImageSession = MemoryImageSession(
            imageId: UUID().uuidString,
            image: image,
            peopleShown: peopleShown,
            personSessions: [],
            overallReflection: nil,
            timestamp: Date()
        )

        totalSteps = (peopleShown.count * stepsPerPerson) + 1   // + final group question
        currentStep = 0

        print("Image session started for imageId:", currentImageSession?.imageId ?? "nil")
        print("Progress initialized:", currentStep, "/", totalSteps)
    }



    func beginSession(for person: String, relation: String) {
        sessionInProgress = true
        lastStep = .identifyPerson

        currentSession = MemorySessionData(
            personName: person,
            relation: relation,
            textAnswers: [],
            mcqAnswers: [],
            emotion: nil,
            finalReflection: nil,
            wasIdentifiedCorrectly: nil,
            timestamp: Date()
        )
    }

    func setIdentificationResult(correct: Bool) {
        currentSession?.wasIdentifiedCorrectly = correct
    }

    func addTextAnswer(question: String, answer: String) {
        currentSession?.textAnswers.append(
            TextAnswer(question: question, answer: answer)
        )
    }

    func addMCQAnswer(question: String, selected: String) {
        currentSession?.mcqAnswers.append(
            MCQAnswer(question: question, selectedOption: selected)
        )
    }

    func setEmotion(_ emotion: String) {
        currentSession?.emotion = emotion
    }

    func setFinalReflection(_ text: String) {
        currentSession?.finalReflection = text
    }

    func completeSession() {
        guard let personSession = currentSession else {
            print("Tried to complete session but currentSession is nil.")
            return
        }

        currentImageSession?.personSessions.append(personSession)

        print("Completed session for", personSession.personName)

        currentSession = nil
        sessionInProgress = false
        lastStep = .completed
    }

    func finishImageSession(overallReflection: String?) {
        print("Saving final image reflection:", overallReflection ?? "nil")

        currentImageSession?.overallReflection = overallReflection

        if let finished = currentImageSession {
            completedImageSessions.append(finished)
            print("Saved completed image session with \(finished.personSessions.count) person responses.")
        }

        currentImageSession = nil
    }


    func advanceProgress() -> Float {
        guard totalSteps > 0 else { return 0 }

        if currentStep < totalSteps {
            currentStep += 1
        }

        return Float(currentStep) / Float(totalSteps)
    }

    func currentProgress() -> Float {
        guard totalSteps > 0 else { return 0 }
        return Float(currentStep) / Float(totalSteps)
    }
}
