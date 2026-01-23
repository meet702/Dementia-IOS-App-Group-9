//
//  SudokuDifficulty.swift
//  Match the Pairs Test
//
//  Created by SDC-USER on 28/11/25.
//

enum SudokuDifficulty {
    case easy, medium, hard

    var clueCount: Int {
        switch self {
        case .easy: return 40
        case .medium: return 34
        case .hard: return 28
        }
    }
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
}
