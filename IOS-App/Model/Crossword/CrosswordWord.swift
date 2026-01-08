//
//  CrosswordWord.swift
//  IOS-App
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

enum Direction {
    case across
    case down
}

struct CrosswordWord {
    let number: Int
    let answer: String
    let startIndex: Int
    let direction: Direction
    let image: UIImage
}
