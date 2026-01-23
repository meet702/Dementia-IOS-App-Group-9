
//
//  Date.swift
//  IOS-App
//
//  Created by SDC-USER on 17/12/25.
//

import UIKit

extension Date {

    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, yyyy"   // 3 Oct, 2025
        return formatter.string(from: self)
    }

    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"        // 8:05 AM
        return formatter.string(from: self)
    }
}
