import UIKit
import Supabase

class CaregiverConnectCodeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var finishButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        enableKeyboardDismissOnTap()
        setupUI()
    }

    var verifiedPhone: String = ""
    var caregiverName: String = ""
    var caregiverGender: String = ""
    var caregiverRelation: String = ""

    private func setupUI() {


        finishButton.layer.cornerRadius = 27
        codeTextField.layer.cornerRadius = 24
        codeTextField.keyboardType = .numberPad
        //codeTextField.setLeftPadding(12)

        codeTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter patients phone number",
            attributes: [
                .foregroundColor: UIColor.systemGray3,
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
    }

    // Add this helper to CaregiverConnectCodeViewController
    private func normalizePhone(_ phone: String) -> String {
        let digits = phone.filter { $0.isNumber }
        return digits.hasPrefix("91") ? "+\(digits)" : "+91\(digits)"
    }

    // MARK: Actions

    @IBAction func finishTapped(_ sender: UIButton) {

        let phone = normalizePhone(codeTextField.text ?? "")

        guard !phone.isEmpty else {
            showAlert("Please enter the patient's phone number.")
            return
        }

        guard let caregiverUid = SupabaseManager.shared.client.auth.currentUser?.id else {
            showAlert("You are not logged in. Please restart the app.")
            return
        }

        // ✅ Disable button to prevent double taps
        finishButton.isEnabled = false

        Task {
            do {
                try await SupabaseSyncManager.shared.connectCaregiverToPatient(
                    patientPhone: phone,
                    caregiverUid: caregiverUid,
                    caregiverRelation: caregiverRelation
                )

                // ✅ Now create the caregiver's own profile
                let caregiverProfile = UserProfile(
                    uid: caregiverUid,
                    name: caregiverName,
                    phone: verifiedPhone,
                    role: .caregiver,
                    gender: caregiverGender,  // ✅ add this
                    caregiverUid: nil,
                    createdAt: Date(),
                    caregiverRelation: nil
                )

                try await SupabaseSyncManager.shared.createUserProfile(caregiverProfile)
                SessionManager.shared.currentUserProfile = caregiverProfile
                SessionManager.shared.populateFromProfile(caregiverProfile)
                
                if let patientProfile = try? await SupabaseSyncManager.shared.fetchPatientProfile(caregiverUid: caregiverUid) {
                    SessionManager.shared.patientName = patientProfile.name
                    SessionManager.shared.patientContact = patientProfile.phone
                    SessionManager.shared.saveToDefaults()
                }

                await MainActor.run {
                    self.performSegue(withIdentifier: "goToCaregiverHome", sender: nil)
                }

            } catch {
                await MainActor.run {
                    self.finishButton.isEnabled = true
                    self.showAlert(error.localizedDescription)
                }
            }
        }
    }

    // MARK: Alert

    private func showAlert(_ message: String) {

        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: Padding Helper

private extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 1))
        leftView = view
        leftViewMode = .always
    }
}
