//
//  SudokuCell.swift
//  Match the Pairs Test
//
//  Created by SDC-USER on 28/11/25.
//
import Foundation

struct SudokuCellModel {
    var value: Int?
    var isGiven: Bool
    var isConflict: Bool  
    init(value: Int? = nil, isGiven: Bool = false) {
        self.value = value
        self.isGiven = isGiven
        self.isConflict = false
    }
}
