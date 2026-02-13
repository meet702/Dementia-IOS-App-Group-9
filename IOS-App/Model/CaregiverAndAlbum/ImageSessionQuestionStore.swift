//
//  ImageSessionQuestionStore.swift
//  IOS-App
//
//  Created by SDC-USER on 02/02/26.
//

import Foundation


final class ImageSessionQuestionStore {
    static let shared = ImageSessionQuestionStore()
    private init() {}

    private var questions: [ImageSessionQuestion] = []

    func overallReflection(for imageSessionID: UUID) -> String {
        questions.first { $0.imageSessionID == imageSessionID }?.responseText ?? "This moment was revisited together."
    }
}
