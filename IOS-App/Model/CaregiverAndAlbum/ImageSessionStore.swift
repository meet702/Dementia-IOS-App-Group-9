//
//  ImageSessionStore.swift
//  IOS-App
//
//  Created by SDC-USER on 02/02/26.
//

import Foundation


final class ImageSessionStore {

    static let shared = ImageSessionStore()
    private init() {}

    private(set) var sessions: [ImageSession] = []

    func addSession(_ session: ImageSession) {
        sessions.insert(session, at: 0)
    }

    func sessionsForToday() -> [ImageSession] {
        let today = Calendar.current.startOfDay(for: Date())
        return sessions.filter {
            Calendar.current.isDate($0.startedAt, inSameDayAs: today)
        }
    }
}
