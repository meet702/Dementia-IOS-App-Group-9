//
//  HomeProfileTableViewController.swift
//  Match the Pairs Test
//
//  Created by SDC-USER on 11/12/25.
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

    private func populateProfile() {
        guard let profile = SessionManager.shared.currentUserProfile else {
            print("currentUserProfile is nil")
            return
        }

        mainNameLabel.text = profile.name
        genderLabel.text = profile.gender ?? "—"
        dobLabel.text = profile.dob ?? "—"

        guard let caregiverUid = profile.caregiverUid else {
            caregiverContactInfo.text = "—"
            caregiverRelation.text = "—"
            return
        }

        Task {
            do {
                let caregiverProfile = try await SupabaseSyncManager.shared.fetchUserProfile(uid: caregiverUid)
                await MainActor.run {
                    self.caregiverName.text = caregiverProfile?.name ?? "—"
                    self.caregiverContactInfo.text = caregiverProfile?.phone ?? "—"
                    self.caregiverRelation.text = profile.caregiverRelation ?? "—"
                }
            } catch {
                print("Failed to fetch caregiver profile:", error)
            }
        }
    }

    @IBAction func donebutton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
