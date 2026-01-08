//
//  Model.swift
//  IOS-App
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

struct CrosswordCell {
    let index: Int
    let row: Int
    let col: Int

    let number: Int?        // serial number (1,2,3…)
    var letter: Character?
    let isBlocked: Bool

    var isHighlighted: Bool
    var isCorrect: Bool
}
