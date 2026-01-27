//
//  Model.swift
//  TempApp
//
//  Created by SDC-USER on 25/11/25.
//

import Foundation

struct DateModel {
    let date: Date
    let dayString: String
    let dateString: String
}

struct TaskModel {
    var id: UUID = UUID()
    var title: String
    var description: String?
    var time: Date
    var isCompleted: Bool
    var isRecurring: Bool = false
    var recurrenceID: UUID? = nil
    
}
