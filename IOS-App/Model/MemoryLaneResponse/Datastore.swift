//
//  Datastore.swift
//  MemoryLaneResponseFeature
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit
import Foundation

class DataStore {
    static let shared = DataStore()
    
    var currentImageSession: ImageSession?
    
    init() {
        loadSampleData()
    }
    
    func loadSampleData() {
        
        let friendTextAnswers: [TextAnswer] = [TextAnswer(question: "What do you call them or how did others address them?", answer: "Chhotu", symbol: "tag"),
                                               TextAnswer(question: "Do you recall any memorable moment with them?", answer: "Beach picnic, 2015", symbol: "heart")]
        let friendMcqAnswers: [MCQAnswer] = [MCQAnswer(question: "Where did you mostly know this person from?", selectedOption: ["Neighbourhood", "Community/Religious Group"], symbol: "location"),
                                             MCQAnswer(question: "Which simple activity do you enjoy together most?", selectedOption: ["Walks", "Talking", "Celebrations"], symbol: "pencil.and.scribble")]
        
        let familyTextAnswers: [TextAnswer] = [TextAnswer(question: "What do you call them or how did others address them?", answer: "Mani", symbol: "tag"),
                                               TextAnswer(question: "Do you recall any memorable moment with them?", answer: "Trip to Manali", symbol: "heart")]
        let familyMcqAnswers: [MCQAnswer] = [MCQAnswer(question: "Where do you most often see them?", selectedOption: ["Events", "School"], symbol: "location"),
                                             MCQAnswer(question: "Which simple activity did you enjoy together most?", selectedOption: ["Talking/Visiting", "TV/Music"], symbol: "pencil.and.scribble")]
        
        let workTextAnswers: [TextAnswer] = [TextAnswer(question: "What do you call them or how did others address them?", answer: "Priya", symbol: "tag"),
                                             TextAnswer(question: "Do you recall any memorable moment with them?", answer: "The time when everyone burst out laughing on Priya’s jokes during a serious team meeting.", symbol: "heart")]
        let workMcqAnswers: [MCQAnswer] = [MCQAnswer(question: "Which kind of task do you remember doing together?", selectedOption: ["Training", "Teaching"], symbol: "location"),
                                           MCQAnswer(question: "Which daily work routine did you share?", selectedOption: ["Morning breaks", "Team meetings"], symbol: "pencil.and.scribble")]
        
        let personSessions = [PersonSession(personName: "Priyadarshan", relation: "Friend", image: "priyadarshanImage", textAnswers: friendTextAnswers, mcqAnswers: friendMcqAnswers, emotion: "Happy", wasIdentifiedCorrectly: false),
                              PersonSession(personName: "Priyamani", relation: "Family", image: "priyamaniImage", textAnswers: familyTextAnswers, mcqAnswers: familyMcqAnswers, emotion: "Happy", wasIdentifiedCorrectly: true),
                              PersonSession(personName: "Priya", relation: "Work", image: "priyaImage", textAnswers: workTextAnswers, mcqAnswers: workMcqAnswers, emotion: "Calm", wasIdentifiedCorrectly: false)]
        
        let imageSession = ImageSession(image: "groupImage",
                                        peopleShown: ["Priyadarshan, Priyamani, Priya"],
                                        personSessions: personSessions,
                                        overallReflection: "We visited Priyamani’s house for a pooja ceremony ❤️. The atmosphere was warm and filled with laughter 😄. Everyone was dressed in traditional clothes, and the house smelled of fresh flowers and incense. It was a beautiful day, and we enjoyed each other's company. We also took some photos to remember this special moment.",
                                        timestamp: Date())
        
        self.currentImageSession = imageSession

    }
}
