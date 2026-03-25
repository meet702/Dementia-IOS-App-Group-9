//
//  CrosswordDataManager.swift
//  IOS-App
//
//  Created by SDC-USER on 24/03/26.
//


import Foundation

func saveCrosswordDataToUserDefaults(_ jsonData: Data) {
    UserDefaults.standard.set(jsonData, forKey: "crosswordData")
}

func loadCrosswordData() -> CrosswordCategoryData? {
    guard let data = UserDefaults.standard.data(forKey: "crosswordData") else {
        return nil
    }
    
    return try? JSONDecoder().decode(CrosswordCategoryData.self, from: data)
}
