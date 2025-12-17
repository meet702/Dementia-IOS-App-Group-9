//
//  keyboard.swift
//  IOS-App
//
//  Created by SDC-USER on 17/12/25.
//

import UIKit

extension UIViewController {

    /// Call once (usually in viewDidLoad)
    func enableKeyboardDismissOnTap() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(_dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func _dismissKeyboard() {
        view.endEditing(true)
    }
}
