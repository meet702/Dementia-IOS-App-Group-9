//
//  PersonEmbeddingStore.swift
//  IOS-App
//
//  Created by SDC-USER on 06/02/26.
//

import Foundation
final class PersonEmbeddingStore {

    static let shared = PersonEmbeddingStore()
    private init() { load() }

    private var embeddings: [UUID: [[Float]]] = [:]
    private let fileName = "person_embeddings.json"

    // MARK: - Public API

    func addEmbedding(_ embedding: [Float], for personID: UUID) {
        embeddings[personID, default: []].append(embedding)
        save()
    }

    func allPersons() -> [(personID: UUID, embeddings: [[Float]])] {
        embeddings.map { ($0.key, $0.value) }
    }

    // MARK: - Persistence

    private func fileURL() -> URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(embeddings) else { return }
        try? data.write(to: fileURL())
    }

    private func load() {
        guard
            let data = try? Data(contentsOf: fileURL()),
            let decoded = try? JSONDecoder().decode([UUID: [[Float]]].self, from: data)
        else { return }

        embeddings = decoded
    }
}
