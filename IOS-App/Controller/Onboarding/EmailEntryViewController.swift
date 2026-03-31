import UIKit

class EmailEntryViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        enableKeyboardDismissOnTap()
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
    }

    @IBAction func continueTapped(_ sender: UIButton) {
        let email = emailTextField.text?.trimmingCharacters(in: .whitespaces).lowercased() ?? ""

        guard isValidEmail(email) else {
            showAlert("Enter a valid email address")
            return
        }

        continueButton.isEnabled = false

        Task {
            do {
                try await SupabaseSyncManager.shared.sendEmailOTP(email: email)

                await MainActor.run {
                    SessionManager.shared.patientContact = email
                    self.performSegue(withIdentifier: "showOTPVerification", sender: email)
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

    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return email.range(of: regex, options: .regularExpression) != nil
    }

    private func showAlert(_ msg: String) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
}