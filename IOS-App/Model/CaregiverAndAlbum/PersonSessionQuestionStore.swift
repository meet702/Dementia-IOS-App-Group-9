//
//  PersonSessionQuestionStore.swift
//  IOS-App
//
//  Created by SDC-USER on 02/02/26.
//

import Foundation

final class PersonSessionQuestionStore {

    static let shared = PersonSessionQuestionStore()
    private init() {
        load()
    }

    private var items: [PersonSessionQuestion] = []

    private let fileURL: URL = {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("person_session_questions.json")
    }()

    func add(_ question: PersonSessionQuestion) {
        guard !items.contains(where: { $0.psqid == question.psqid }) else { return }
        items.append(question)
        save()
    }

    func questions(for personSessionID: UUID) -> [PersonSessionQuestion] {
        items.filter { $0.psid == personSessionID }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([PersonSessionQuestion].self, from: data)
        else { return }

        items = decoded
    }
    func clearAll() {
        try? FileManager.default.removeItem(at: fileURL)  // use whatever your file URL property is named
        print("🧹 PersonSessionQuestionStore cleared")
    }
    
}

