//
//  PersonSessionStore.swift
//  IOS-App
//
//  Created by SDC-USER on 02/02/26.
//

import Foundation


final class PersonSessionStore {
    static let shared = PersonSessionStore()
    private init() {}

    private var sessions: [PersonSession] = []

    func add(_ session: PersonSession) {
        sessions.append(session)
    }

    func personSessions(for imageSessionID: UUID) -> [PersonSession] {
        sessions.filter { $0.imageSessionID == imageSessionID }
    }
}
