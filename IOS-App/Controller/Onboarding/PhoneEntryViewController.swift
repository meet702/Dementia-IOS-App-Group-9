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
        
    }

    @IBAction func continueTapped(_ sender: UIButton) {
        let phone = normalizePhone(phoneTextField.text ?? "")

        guard phone.count >= 10 else {
            showAlert("Enter a valid phone number")
            return
        }

        continueButton.isEnabled = false

        Task {
            do {
                try await SupabaseSyncManager.shared.sendOTP(phone: phone)

                await MainActor.run {
                    
                    SessionManager.shared.patientContact = phone
                    
                    self.performSegue(
                        withIdentifier: "showOTPVerification",
                        sender: phone
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
           let phone = sender as? String {
            dest.phone = phone
        }
    }

    private func normalizePhone(_ phone: String) -> String {
        let digits = phone.filter { $0.isNumber }
        return digits.hasPrefix("91") ? "+\(digits)" : "+91\(digits)"
    }

    private func showAlert(_ msg: String) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }

}
