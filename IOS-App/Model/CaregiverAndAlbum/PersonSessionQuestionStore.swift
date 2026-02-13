//
//  PersonSessionQuestionStore.swift
//  IOS-App
//
//  Created by SDC-USER on 02/02/26.
//

import Foundation


final class PersonSessionQuestionStore {

    static let shared = PersonSessionQuestionStore()
    private init() {}

    private var items: [PersonSessionQuestion] = []

    func add(_ question: PersonSessionQuestion) {
        items.append(question)
    }

    func questions(for personSessionID: UUID) -> [PersonSessionQuestion] {
        items.filter { $0.personSessionID == personSessionID }
    }
}

