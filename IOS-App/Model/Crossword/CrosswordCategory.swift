//
//  CrosswordCategory.swift
//  IOS-App
//
//  Created by SDC-USER on 14/01/26.
//

import Foundation

enum CrosswordCategory: String {
    case countries = "Countries"
    case dailyObjects = "Daily Objects"
    case gk = "GK"
    case food = "Food"
    
    var data: [CountryData] {
        switch self {
        case .countries:
            return allCountries
        case .dailyObjects:
            return dailyObjectsData
        case .gk:
            return gkData
        case .food:
            return foodData
        }
    }
}
