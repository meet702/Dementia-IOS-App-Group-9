//
//  CrosswordGameState.swift
//  IOS-App
//
//  Created by SDC-USER on 08/01/26.
//

import Foundation

final class CrosswordGameState {
    var selectedWord: CrosswordWord?
    var selectedDirection: Direction = .across
    var selectedCellIndex: Int?
}
