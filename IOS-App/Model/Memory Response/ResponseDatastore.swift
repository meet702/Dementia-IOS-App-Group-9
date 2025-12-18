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
        
        var component1 = DateComponents()
        component1.year = 2025
        component1.month = 12
        component1.day = 17
        component1.hour = 14
        component1.minute = 30
        let date1 = Calendar.current.date(from: component1)!
        
        var component2 = DateComponents()
        component2.year = 2025
        component2.month = 12
        component2.day = 16
        component2.hour = 17
        component2.minute = 00
        let date2 = Calendar.current.date(from: component2)!
        
        var component3 = DateComponents()
        component3.year = 2025
        component3.month = 12
        component3.day = 16
        component3.hour = 13
        component3.minute = 05
        let date3 = Calendar.current.date(from: component3)!
        
        var component4 = DateComponents()
        component4.year = 2025
        component4.month = 12
        component4.day = 13
        component4.hour = 20
        component4.minute = 36
        let date4 = Calendar.current.date(from: component4)!
        
        var component5 = DateComponents()
        component5.year = 2025
        component5.month = 12
        component5.day = 12
        component5.hour = 15
        component5.minute = 45
        let date5 = Calendar.current.date(from: component5)!
        
        var component6 = DateComponents()
        component6.year = 2025
        component6.month = 12
        component6.day = 11
        component6.hour = 13
        component6.minute = 29
        let date6 = Calendar.current.date(from: component6)!
        
        
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
                                         timestamp: date2)
                                         
        let imageSession3 = ImageSession(image: "image 67",
                                         peopleShown: ["Priyadarshan, Priyamani, Priya"],
                                         personSessions: personSessions1,
                                         overallReflection: "We visited Priyamani’s house for a pooja ceremony ❤️. The atmosphere was warm and filled with laughter 😄. Everyone was dressed in traditional clothes, and the house smelled of fresh flowers and incense. It was a beautiful day, and we enjoyed each other's company. We also took some photos to remember this special moment.",
                                         timestamp: date3)
        
        let imageSession4 = ImageSession(image: "image 68",
                                         peopleShown: ["Priyadarshan, Priyamani, Priya"],
                                         personSessions: personSessions1,
                                         overallReflection: "We visited Priyamani’s house for a pooja ceremony ❤️. The atmosphere was warm and filled with laughter 😄. Everyone was dressed in traditional clothes, and the house smelled of fresh flowers and incense. It was a beautiful day, and we enjoyed each other's company. We also took some photos to remember this special moment.",
                                         timestamp: date4)
        
        let imageSession5 = ImageSession(image: "image 69",
                                         peopleShown: ["Priyadarshan, Priyamani, Priya"],
                                         personSessions: personSessions1,
                                         overallReflection: "We visited Priyamani’s house for a pooja ceremony ❤️. The atmosphere was warm and filled with laughter 😄. Everyone was dressed in traditional clothes, and the house smelled of fresh flowers and incense. It was a beautiful day, and we enjoyed each other's company. We also took some photos to remember this special moment.",
                                         timestamp: date5)
        
        let imageSession6 = ImageSession(image: "image 70",
                                         peopleShown: ["Priyadarshan, Priyamani, Priya"],
                                         personSessions: personSessions1,
                                         overallReflection: "We visited Priyamani’s house for a pooja ceremony ❤️. The atmosphere was warm and filled with laughter 😄. Everyone was dressed in traditional clothes, and the house smelled of fresh flowers and incense. It was a beautiful day, and we enjoyed each other's company. We also took some photos to remember this special moment.",
                                         timestamp: date6)
        
        imageSession = [imageSession1, imageSession2, imageSession3, imageSession4, imageSession5, imageSession6]
        self.currentImageSession = imageSession.first

    }
}
