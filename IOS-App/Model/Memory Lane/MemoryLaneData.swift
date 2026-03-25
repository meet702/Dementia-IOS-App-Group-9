//
//  MemoryLaneData.swift
//  IOS-App
//
//  Created by SDC-USER on 24/03/26.
//


import Foundation

struct MemoryLaneData: Codable {
    let mcqQuestions: [Question]
    let textQuestions: [Question]
    let reflectionQuestion: Question
    let prompts: PromptData
}

struct PromptData: Codable {
    let memoryIntro: [String]
    let personIntro: [String]
    let fallback: [String]
    let momentReflection: [String]
}