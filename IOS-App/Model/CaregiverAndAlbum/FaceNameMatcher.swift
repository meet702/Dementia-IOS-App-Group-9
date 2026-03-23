////
////  FaceNameMatcher.swift
////  IOS-App
////
////  Created by SDC-USER on 06/02/26.
////
//
//import Foundation
//final class FaceNameMatcher {
//
//    static let shared = FaceNameMatcher()
//    private init() {}
//
//    private let threshold: Float = 0.65
//
//    func matchPerson(for embedding: [Float]) -> UUID? {
//
//        var bestPerson: UUID?
//        var bestSim: Float = -1
//
//        for (personID, vectors) in PersonEmbeddingStore.shared.allPersons() {
//            for v in vectors {
//
//                let sim = cosineSimilarity(embedding, v)
//
//                if sim > bestSim {
//                    bestSim = sim
//                    bestPerson = personID
//                }
//            }
//        }
//
//        if bestSim > threshold {
//            return bestPerson
//        }
//
//        return nil
//    }
//
//    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
//        zip(a, b).map(*).reduce(0, +)
//    }
//    
//
//}
