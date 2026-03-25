//
//  DataStore.swift
//  IOS-App
//

import Foundation

final class AppDataStore {

    static let shared = AppDataStore()
    
    private var data: MemoryLaneData?
    
    var reflectionQuestion: Question? {
        return data?.reflectionQuestion
    }

    private init() {
        data = loadMemoryLaneData()
    }

    func defaultQuestions() -> [Question] {
        var questions: [Question] = []
        
        if let mcq = data?.mcqQuestions.randomElement() {
            questions.append(mcq)
        }
        
        if let text = data?.textQuestions.randomElement() {
            questions.append(text)
        }
        
        return questions
    }
    

    func question(for id: UUID) -> Question? {

        let allQuestions =
            (data?.mcqQuestions ?? []) +
            (data?.textQuestions ?? []) +
            ([data?.reflectionQuestion].compactMap { $0 })

        return allQuestions.first { $0.qid == id }
    }

    func prompt(for id: UUID) -> String {
        question(for: id)?.prompt ?? "Reflection"
    }


    func randomMCQ() -> Question? {
        data?.mcqQuestions.randomElement()
    }

    func randomTextQuestion() -> Question? {
        data?.textQuestions.randomElement()
    }

    func randomPersonIntro() -> String {
        data?.prompts.personIntro.randomElement() ?? ""
    }

    func randomFallbackStatement() -> String {
        data?.prompts.fallback.randomElement() ?? ""
    }

    func randomMomentPrompt() -> String {
        data?.prompts.momentReflection.randomElement() ?? ""
    }
}
