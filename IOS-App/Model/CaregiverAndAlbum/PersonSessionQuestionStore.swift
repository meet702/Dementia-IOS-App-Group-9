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
        items.append(question)
        save()
    }

    func questions(for personSessionID: UUID) -> [PersonSessionQuestion] {
        items.filter { $0.personSessionID == personSessionID }
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
}

