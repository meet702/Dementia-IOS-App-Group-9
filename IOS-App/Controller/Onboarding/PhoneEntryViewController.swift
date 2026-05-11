//
//  PhoneEntryViewController.swift
//  IOS-App
//
//  Created by SDC-USER on 16/03/26.
//

import UIKit

class PhoneEntryViewController: UIViewController {
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        enableKeyboardDismissOnTap()
        // Do any additional setup after loading the view.
        
        // Set keyboard type to email
        phoneTextField.keyboardType = .emailAddress
        phoneTextField.autocapitalizationType = .none
        phoneTextField.autocorrectionType = .no
    }

    @IBAction func continueTapped(_ sender: UIButton) {
        let email = (phoneTextField.text ?? "").trimmingCharacters(in: .whitespaces).lowercased()

        guard !email.isEmpty, email.contains("@"), email.contains(".") else {
            showAlert("Enter a valid email address")
            return
        }

        continueButton.isEnabled = false

        Task {
            do {
                try await SupabaseSyncManager.shared.sendOTP(email: email)

                await MainActor.run {
                    
                    SessionManager.shared.patientContact = email
                    
                    self.performSegue(
                        withIdentifier: "showOTPVerification",
                        sender: email
                    )
                }
            } catch {
                await MainActor.run {
                    self.continueButton.isEnabled = true
                    self.showAlert(error.localizedDescription)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOTPVerification",
           let dest = segue.destination as? OTPVerificationViewController,
           let email = sender as? String {
            dest.email = email
        }
    }

    private func showAlert(_ msg: String) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }

}
