import UIKit
import Supabase

class OTPVerificationViewController: UIViewController {

    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!

    @IBOutlet weak var phoneNumberLabel: UILabel!
    var email: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        enableKeyboardDismissOnTap()
        phoneNumberLabel.text = "Code sent to \(email)"
    }

    @IBAction func verifyTapped(_ sender: UIButton) {
        let otp = otpTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""

        guard otp.count == 6 else {
            showAlert("Enter the 6-digit code")
            return
        }

        verifyButton.isEnabled = false

        Task {
            do {
                try await SupabaseSyncManager.shared.verifyOTP(email: email, otp: otp)

                guard let uid = SupabaseManager.shared.client.auth.currentUser?.id else {
                    return
                }

                let existingProfile = try await SupabaseSyncManager.shared.fetchUserProfile(uid: uid)

                if let profile = existingProfile {

                    SessionManager.shared.currentUserProfile = profile
                    SessionManager.shared.populateFromProfile(profile)
                    SessionManager.shared.clearLocalDataForNewUser()

                    let loadingVC = RestoringMemoriesViewController()
                    loadingVC.modalPresentationStyle = .fullScreen
                    self.present(loadingVC, animated: true)

                    let progressTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
                        let current = loadingVC.currentProgress
                        if current < 0.85 {
                            let increment = Float.random(in: 0.02...0.05)
                            loadingVC.setProgress(min(current + increment, 0.85))
                        } else {
                            timer.invalidate()
                        }
                    }
                    RunLoop.main.add(progressTimer, forMode: .common)

                    await SupabaseSyncManager.shared.restoreAllData()

                    if profile.role == .caregiver {
                        if let patientProfile = try? await SupabaseSyncManager.shared.fetchPatientProfile(caregiverUid: profile.uid) {

                            SessionManager.shared.patientName = patientProfile.name
                            SessionManager.shared.patientContact = patientProfile.email
                            SessionManager.shared.saveToDefaults()
                        } else {
                        }
                    } else {
                    }

                    progressTimer.invalidate()
                    await MainActor.run {
                        loadingVC.setProgress(1.0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            loadingVC.dismiss(animated: false)
                            self.navigateToHome(role: profile.role)
                        }
                    }

                } else {

                    await MainActor.run {
                        self.performSegue(withIdentifier: "showRoleSelection", sender: nil)
                    }
                }

            } catch {
                await MainActor.run {
                    self.verifyButton.isEnabled = true
                    self.showAlert(error.localizedDescription)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRoleSelection",
           let dest = segue.destination as? OnboardingRoleSelectionViewController {
            dest.verifiedEmail = email
        }
    }

    private func navigateToHome(role: UserProfile.UserRole) {
        if role == .caregiver {
            let storyboard = UIStoryboard(name: "Caregiver", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CaregiverHomeNav")
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        } else {
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PatientHomeNav")
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }

    private func showAlert(_ msg: String) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
