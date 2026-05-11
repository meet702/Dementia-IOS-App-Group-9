//
//  HomeProfileTableViewController.swift
//  IOS-App
//

import UIKit

class HomeProfileTableViewController: UITableViewController {

    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var caregiverName: UILabel!
    @IBOutlet weak var caregiverContactInfo: UILabel!
    @IBOutlet weak var caregiverRelation: UILabel!
    @IBOutlet weak var mainNameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        populateProfile()
    }

    // MARK: - Data Loading

    private func populateProfile() {
        guard let profile = SessionManager.shared.currentUserProfile else {
            print("❌ currentUserProfile is nil")
            return
        }

        // Patient's own data
        mainNameLabel.text = profile.name
        genderLabel.text   = profile.gender ?? "—"
        dobLabel.text      = profile.dob    ?? "—"

        // Family Member section — needs caregiver's profile
        guard let caregiverUid = profile.caregiverUid else {
            caregiverContactInfo.text = "—"
            caregiverRelation.text    = "—"
            caregiverName.text        = "—"
            return
        }

        Task {
            do {
                let caregiverProfile = try await SupabaseSyncManager.shared.fetchUserProfile(uid: caregiverUid)
                await MainActor.run {
                    self.caregiverName.text        = caregiverProfile?.name  ?? "—"
                    self.caregiverContactInfo.text = caregiverProfile?.email ?? "—"
                    self.caregiverRelation.text    = profile.caregiverRelation ?? "—"
                }
            } catch {
                print("❌ Failed to fetch caregiver profile:", error)
            }
        }
    }

    // MARK: - Actions

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
