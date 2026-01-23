//
//  CrosswordWord.swift
//  IOS-App
//
//  Created by SDC-USER on 08/01/26.
//
enum CrosswordDirection {
    case across
    case down
}

struct CrosswordWord {
    let number: Int
    let answer: String
    let clue: String
    let startIndex: Int
    let direction: CrosswordDirection

    var globalDirection: GlobalDirection {
        return direction == .across ? .across : .down
    }
}


