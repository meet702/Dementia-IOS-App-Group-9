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
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var relationLabel: UILabel!
    
    let profileData: HomeProfile = HomeProfile(dateOfBirth: "12 Oct 1965 (60)", gender: "Male", codeForCareiver: "172560", caregiverName: "Aayudh", relationWithCaregiver: "Son", caregiverContact: "9927654344")
    
    func setProfile(profileInfo: HomeProfile) {
        dobLabel.text = profileInfo.dateOfBirth
        genderLabel.text = profileInfo.gender
        codeLabel.text = profileInfo.codeForCareiver
        relationLabel.text = profileInfo.relationWithCaregiver
        nameLabel.text = profileInfo.caregiverName
        contactLabel.text = profileInfo.caregiverContact
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProfile(profileInfo: profileData)
    }

    @IBAction func donebutton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
