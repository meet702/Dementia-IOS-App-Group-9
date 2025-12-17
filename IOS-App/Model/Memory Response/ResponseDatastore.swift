//
//  Datastore.swift
//  MemoryLaneResponseFeature
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit
import Foundation

class ResponseDataStore {
    static let shared = ResponseDataStore()
    
    var imageSession: [ImageSession] = []
    var currentImageSession: ImageSession?
    
    init() {
        loadSampleData()
    }
    
    func loadSampleData() {
        
        let friendTextAnswers: [TextAnswerCaregiver] = [TextAnswerCaregiver(question: "What do you call them or how did others address them?", answer: "Chhotu", symbol: "tag"),
                                               TextAnswerCaregiver(question: "Do you recall any memorable moment with them?", answer: "Beach picnic, 2015", symbol: "heart")]
        let friendMcqAnswers: [MCQAnswerCaregiver] = [MCQAnswerCaregiver(question: "Where did you mostly know this person from?", selectedOption: ["Neighbourhood", "Community/Religious Group"], symbol: "location"),
                                             MCQAnswerCaregiver(question: "Which simple activity do you enjoy together most?", selectedOption: ["Walks", "Talking", "Celebrations"], symbol: "pencil.and.scribble")]
        
        let familyTextAnswers: [TextAnswerCaregiver] = [TextAnswerCaregiver(question: "What do you call them or how did others address them?", answer: "Mani", symbol: "tag"),
                                               TextAnswerCaregiver(question: "Do you recall any memorable moment with them?", answer: "Trip to Manali", symbol: "heart")]
        let familyMcqAnswers: [MCQAnswerCaregiver] = [MCQAnswerCaregiver(question: "Where do you most often see them?", selectedOption: ["Events", "School"], symbol: "location"),
                                             MCQAnswerCaregiver(question: "Which simple activity did you enjoy together most?", selectedOption: ["Talking/Visiting", "TV/Music"], symbol: "pencil.and.scribble")]
        
        let workTextAnswers: [TextAnswerCaregiver] = [TextAnswerCaregiver(question: "What do you call them or how did others address them?", answer: "Priya", symbol: "tag"),
                                             TextAnswerCaregiver(question: "Do you recall any memorable moment with them?", answer: "The time when everyone burst out laughing on Priya’s jokes during a serious team meeting.", symbol: "heart")]
        let workMcqAnswers: [MCQAnswerCaregiver] = [MCQAnswerCaregiver(question: "Which kind of task do you remember doing together?", selectedOption: ["Training", "Teaching"], symbol: "location"),
                                           MCQAnswerCaregiver(question: "Which daily work routine did you share?", selectedOption: ["Morning breaks", "Team meetings"], symbol: "pencil.and.scribble")]
        
        let personSessions1 = [
            PersonSession(personName: "Priyadarshan", relation: "Friend", image: "priyadarshanImage", textAnswers: friendTextAnswers, mcqAnswers: friendMcqAnswers, emotion: "Happy", wasIdentifiedCorrectly: false),
                              
            PersonSession(personName: "Priyamani", relation: "Family", image: "priyamaniImage", textAnswers: familyTextAnswers, mcqAnswers: familyMcqAnswers, emotion: "Happy", wasIdentifiedCorrectly: true),
                              
            PersonSession(personName: "Priya", relation: "Work", image: "priyaImage", textAnswers: workTextAnswers, mcqAnswers: workMcqAnswers, emotion: "Calm", wasIdentifiedCorrectly: false)
        
        ]
        let personSessions2 = [
            PersonSession(personName: "Priyadarshan", relation: "Friend", image: "priyadarshanImage", textAnswers: friendTextAnswers, mcqAnswers: friendMcqAnswers, emotion: "Happy", wasIdentifiedCorrectly: false),
                              
            PersonSession(personName: "Priyamani", relation: "Family", image: "priyamaniImage", textAnswers: familyTextAnswers, mcqAnswers: familyMcqAnswers, emotion: "Happy", wasIdentifiedCorrectly: true),
                              
            PersonSession(personName: "Priya", relation: "Work", image: "priyaImage", textAnswers: workTextAnswers, mcqAnswers: workMcqAnswers, emotion: "Calm", wasIdentifiedCorrectly: false),
            
            PersonSession(personName: "Priyam", relation: "Work", image: "priyam", textAnswers: workTextAnswers, mcqAnswers: workMcqAnswers, emotion: "Calm", wasIdentifiedCorrectly: false)
        
        ]
        
        let imageSession1 = ImageSession(image: "groupImage",
                                        peopleShown: ["Priyadarshan, Priyamani, Priya"],
                                        personSessions: personSessions1,
                                        overallReflection: "We visited Priyamani’s house for a pooja ceremony ❤️. The atmosphere was warm and filled with laughter 😄. Everyone was dressed in traditional clothes, and the house smelled of fresh flowers and incense. It was a beautiful day, and we enjoyed each other's company. We also took some photos to remember this special moment.",
                                        timestamp: Date())
        
        let imageSession2 = ImageSession(image: "image 43",
                                         peopleShown: ["Priyam ,Priyadarshan, Priyamani, Priya"],
                                         personSessions: personSessions2,
                                         overallReflection: "We visited Priyamani’s house for a pooja ceremony ❤️. The atmosphere was warm and filled with laughter 😄. Everyone was dressed in traditional clothes, and the house smelled of fresh flowers and incense. It was a beautiful day, and we enjoyed each other's company. We also took some photos to remember this special moment.",
                                         timestamp: Date())
                                         
        let imageSession3 = ImageSession(image: "image 67",
                                         peopleShown: ["Priyadarshan, Priyamani, Priya"],
                                         personSessions: personSessions1,
                                         overallReflection: "We visited Priyamani’s house for a pooja ceremony ❤️. The atmosphere was warm and filled with laughter 😄. Everyone was dressed in traditional clothes, and the house smelled of fresh flowers and incense. It was a beautiful day, and we enjoyed each other's company. We also took some photos to remember this special moment.",
                                         timestamp: Date())
        
        let imageSession4 = ImageSession(image: "image 68",
                                         peopleShown: ["Priyadarshan, Priyamani, Priya"],
                                         personSessions: personSessions1,
                                         overallReflection: "We visited Priyamani’s house for a pooja ceremony ❤️. The atmosphere was warm and filled with laughter 😄. Everyone was dressed in traditional clothes, and the house smelled of fresh flowers and incense. It was a beautiful day, and we enjoyed each other's company. We also took some photos to remember this special moment.",
                                         timestamp: Date())
        
        let imageSession5 = ImageSession(image: "image 69",
                                         peopleShown: ["Priyadarshan, Priyamani, Priya"],
                                         personSessions: personSessions1,
                                         overallReflection: "We visited Priyamani’s house for a pooja ceremony ❤️. The atmosphere was warm and filled with laughter 😄. Everyone was dressed in traditional clothes, and the house smelled of fresh flowers and incense. It was a beautiful day, and we enjoyed each other's company. We also took some photos to remember this special moment.",
                                         timestamp: Date())
        
        let imageSession6 = ImageSession(image: "image 70",
                                         peopleShown: ["Priyadarshan, Priyamani, Priya"],
                                         personSessions: personSessions1,
                                         overallReflection: "We visited Priyamani’s house for a pooja ceremony ❤️. The atmosphere was warm and filled with laughter 😄. Everyone was dressed in traditional clothes, and the house smelled of fresh flowers and incense. It was a beautiful day, and we enjoyed each other's company. We also took some photos to remember this special moment.",
                                         timestamp: Date())
        
        imageSession = [imageSession1, imageSession2, imageSession3, imageSession4, imageSession5, imageSession6]
        self.currentImageSession = imageSession.first

    }
}
