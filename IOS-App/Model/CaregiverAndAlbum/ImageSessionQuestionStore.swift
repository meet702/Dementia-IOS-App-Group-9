//
//  ImageSessionQuestionStore.swift
//  IOS-App
//
//  Created by SDC-USER on 02/02/26.
//

import Foundation

final class ImageSessionQuestionStore {

    static let shared = ImageSessionQuestionStore()
    private init() {
        load()
    }

    private var questions: [ImageSessionQuestion] = []

    private let fileURL: URL = {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("image_session_questions.json")
    }()

    func add(_ question: ImageSessionQuestion) {
        questions.append(question)
        save()
    }

    func questions(for imageSessionID: UUID) -> [ImageSessionQuestion] {
        questions.filter { $0.isid == imageSessionID }
    }

    func overallReflection(for imageSessionID: UUID) -> String {
        questions.first { $0.isid == imageSessionID }?.responseText
        ?? "This moment was revisited together."
    }

    private func save() {
        if let data = try? JSONEncoder().encode(questions) {
            try? data.write(to: fileURL)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([ImageSessionQuestion].self, from: data)
        else { return }

        questions = decoded
    }
}
