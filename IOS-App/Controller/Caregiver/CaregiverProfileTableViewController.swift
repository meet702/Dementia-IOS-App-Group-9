//
//  ProfileTableViewController.swift
//  Match the Pairs Test
//
//  Created by SDC-USER on 10/12/25.
//

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

        let caregiverName = profile.name
        let caregiverGender = profile.gender ?? "-"

        let patientName = SessionManager.shared.patientName ?? "-"
        let patientContact = SessionManager.shared.patientContact ?? "-"

        caregiverNameLabel.text = caregiverName
        genderLabel.text = caregiverGender
        nameLabel.text = patientName
        contactLabel.text = patientContact
        self.title = caregiverName
    }

    @IBAction func donebutton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
