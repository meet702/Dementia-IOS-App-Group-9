import UIKit

class CaregiverProfileTableViewController: UITableViewController {

    @IBOutlet weak var caregiverNameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfileData()
    }

    func loadProfileData() {
        guard let profile = SessionManager.shared.currentUserProfile else { return }

        caregiverNameLabel.text = profile.name
        genderLabel.text = profile.gender ?? "—"
        self.title = profile.name

        let cachedName    = SessionManager.shared.patientName
        let cachedContact = SessionManager.shared.patientContact

        if let name = cachedName, !name.isEmpty {
            nameLabel.text    = name
            contactLabel.text = cachedContact ?? "—"
        } else {

            nameLabel.text    = "Loading…"
            contactLabel.text = "Loading…"
            fetchPatientFromSupabase(caregiverUid: profile.uid)
        }
    }

    private func fetchPatientFromSupabase(caregiverUid: UUID) {
        Task {
            do {
                if let patient = try await SupabaseSyncManager.shared.fetchPatientProfile(caregiverUid: caregiverUid) {

                    SessionManager.shared.patientName    = patient.name
                    SessionManager.shared.patientContact = patient.email
                    SessionManager.shared.saveToDefaults()

                    await MainActor.run {
                        self.nameLabel.text    = patient.name
                        self.contactLabel.text = patient.email
                    }
                } else {
                    await MainActor.run {
                        self.nameLabel.text    = "—"
                        self.contactLabel.text = "—"
                    }
                }
            } catch {
                print("Failed to fetch patient profile:", error)
                await MainActor.run {
                    self.nameLabel.text    = "—"
                    self.contactLabel.text = "—"
                }
            }
        }
    }

    @IBAction func donebutton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBAction func logoutTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            SessionManager.shared.logout()
        })
        present(alert, animated: true)
    }
}
