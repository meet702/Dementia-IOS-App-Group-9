//
//  MemorySessionManager.swift
//  MemoryLane
//
//  Created by SDC-User on 17/12/25.
//

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

    let stepsPerPerson: Int = 4


    func startImageSession(image: UIImage, peopleShown: [String]) {

        currentImageSession = MemoryImageSession(
            imageId: UUID().uuidString,
            image: image,
            peopleShown: peopleShown,
            personSessions: [],
            overallReflection: nil,
            timestamp: Date()
        )

        totalSteps = (peopleShown.count * stepsPerPerson) + 1
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
        print("\n===== MEMORY LANE SESSION SUMMARY =====\n")

        if let imageSession = currentImageSession {

            for (index, personSession) in imageSession.personSessions.enumerated() {

                print("Person \(index + 1): \(personSession.personName)")
                print("Relation: \(personSession.relation)")
                print("Identified correctly: \(personSession.wasIdentifiedCorrectly ?? false)")

                print("\nText Answers:")
                if personSession.textAnswers.isEmpty {
                    print("  None")
                } else {
                    for answer in personSession.textAnswers {
                        print("  Q: \(answer.question)")
                        print("  A: \(answer.answer)")
                    }
                }

                print("\nMCQ Answers:")
                if personSession.mcqAnswers.isEmpty {
                    print("  None")
                } else {
                    for answer in personSession.mcqAnswers {
                        print("  Q: \(answer.question)")
                        print("  Selected: \(answer.selectedOption)")
                    }
                }

                print("\nEmotion:")
                print("  \(personSession.emotion ?? "Not answered")")

                print("\n------------------------------------\n")
            }

            print("FINAL GROUP REFLECTION:")
            print(overallReflection ?? "No final reflection")

            print("\n=====================================\n")
        }

        currentImageSession?.overallReflection = overallReflection

        if let finished = currentImageSession {
            completedImageSessions.append(finished)
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
