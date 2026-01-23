//
//  Model.swift
//  IOS-App
//
//  Created by SDC-USER on 08/01/26.

struct CrosswordCell {
    let index: Int
    let row: Int
    let col: Int

    var numbers: [Int] = []
    var letter: Character?
    var correctLetter: Character?

    var isBlocked: Bool
    var isHighlighted: Bool

    var isCorrectLetter: Bool  
    var isCorrectWord: Bool
    var isWrongLetter: Bool
    
    var isSelected: Bool = false

}
