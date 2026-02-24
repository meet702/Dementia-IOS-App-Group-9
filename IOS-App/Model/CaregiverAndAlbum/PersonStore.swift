//
//  PersonStore.swift
//  IOS-App
//
//  Created by SDC-USER on 02/02/26.
//

import Foundation


final class PersonStore {

    static let shared = PersonStore()
    private init() {
        load()
    }

    private var people: [UUID: Person] = [:]

    // MARK: - CRUD

    func add(_ person: Person) {
        people[person.pid] = person
        save()
    }

    func person(by id: UUID) -> Person? {
        people[id]
    }

    // MARK: - Persistence

    private let fileURL: URL = {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("people.json")
    }()

    private func save() {
        do {
            let data = try JSONEncoder().encode(Array(people.values))
            try data.write(to: fileURL)
        } catch {
            print("❌ Failed to save people:", error)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([Person].self, from: data)
        else { return }

        people = Dictionary(uniqueKeysWithValues: decoded.map { ($0.pid, $0) })
    }
}
