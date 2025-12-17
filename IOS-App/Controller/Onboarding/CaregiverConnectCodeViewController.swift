//
//  CaregiverConnectCodeViewController.swift
//  onboardingScreen
//
//  Created by SDC-USER on 16/12/25.
//

import UIKit

class CaregiverConnectCodeViewController: UIViewController {
    
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var finishButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        enableKeyboardDismissOnTap()
        setupUI()
    }
    
    private func setupUI() {
        finishButton.layer.cornerRadius = 27

        codeTextField.text = ""
        codeTextField.layer.cornerRadius = 10
        codeTextField.backgroundColor = .white
        codeTextField.font = UIFont.systemFont(ofSize: 16)
        codeTextField.textColor = .darkGray
        codeTextField.setLeftPadding(12)
        codeTextField.keyboardType = .phonePad

        codeTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter code",
            attributes: [
                .foregroundColor: UIColor.systemGray3,
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
    }

    
    @IBAction func finishTapped(_ sender: UIButton) {
        let code = codeTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if code.isEmpty {
            showAlert("Please enter the connection code.")
            return
        }

        print("Entered code:", code)
        
        performSegue(withIdentifier: "goToCaregiverHome", sender: nil)
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

private extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 1))
        leftView = v
        leftViewMode = .always
    }
}
