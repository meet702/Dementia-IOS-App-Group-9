import Foundation

final class PersonSessionStore {

    static let shared = PersonSessionStore()
    private init() {
        load()
    }

    private var sessions: [PersonSession] = []

    private let fileURL: URL = {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("person_sessions.json")
    }()

    func add(_ session: PersonSession) {
        guard !sessions.contains(where: { $0.psid == session.psid }) else { return }
        sessions.append(session)
        save()
    }

    func personSessions(for imageSessionID: UUID) -> [PersonSession] {
        sessions.filter { $0.isid == imageSessionID }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(sessions) {
            try? data.write(to: fileURL)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([PersonSession].self, from: data)
        else { return }

        sessions = decoded
    }

    func clearAll() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
