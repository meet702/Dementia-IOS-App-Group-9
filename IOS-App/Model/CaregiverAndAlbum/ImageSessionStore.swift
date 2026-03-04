//
//  ImageSessionStore.swift
//  IOS-App
//
//  Created by SDC-USER on 02/02/26.
//

import Foundation

final class ImageSessionStore {

    static let shared = ImageSessionStore()
    private init() {
        load()
    }

    private var sessions: [ImageSession] = []

    private let fileURL: URL = {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("image_sessions.json")
    }()

    // MARK: - Public API

    func addSession(_ session: ImageSession) {
        sessions.insert(session, at: 0)
        save()
    }

    func updateSession(_ session: ImageSession) {
        if let index = sessions.firstIndex(where: { $0.isid == session.isid }) {
            sessions[index] = session
            save()
        }
    }

    func allSessions() -> [ImageSession] {
        sessions
    }

    func sessionsForToday() -> [ImageSession] {
        let today = Calendar.current.startOfDay(for: Date())
        return sessions.filter {
            Calendar.current.isDate($0.startedAt, inSameDayAs: today)
        }
    }

    // MARK: - Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(sessions)
            try data.write(to: fileURL)
        } catch {
            print("❌ Failed to save ImageSessions:", error)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([ImageSession].self, from: data)
        else { return }

        sessions = decoded
    }
    
    func latestMemoryLaneSession() -> ImageSession? {
        sessions
            .filter { $0.sessionType == .memoryLane }
            .sorted { $0.startedAt > $1.startedAt }
            .first
    }
    
    func oldestUnviewedSession() -> ImageSession? {
        sessions
            .filter { $0.sessionType == .memoryLane && $0.recapCount == 0 }
            .sorted { $0.startedAt < $1.startedAt }
            .first
    }
}
