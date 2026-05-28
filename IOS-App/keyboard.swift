import UIKit

extension UIViewController {

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
