//
//  MemoryLaneDataManager.swift
//  IOS-App
//
//  Created by SDC-USER on 24/03/26.
//

import Foundation

func loadMemoryLaneData() -> MemoryLaneData? {
    guard let data = UserDefaults.standard.data(forKey: "memoryLaneData") else {
        return nil
    }

    return try? JSONDecoder().decode(MemoryLaneData.self, from: data)
}

func saveMemoryLaneDataToUserDefaults(_ data: Data) {
    UserDefaults.standard.set(data, forKey: "memoryLaneData")
}
