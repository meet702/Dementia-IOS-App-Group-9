//
//  ProfileTableViewController.swift
//  Match the Pairs Test
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class CaregiverProfileTableViewController: UITableViewController {

    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    
    let profileData: CaregiverProfile = CaregiverProfile(dateOfBirth: "22 Feb 1994 (31)", gender: "Male", patientName: "Ks Arjun", patientAddress: "Sankalp Society", patientContact: "9815475752")
    
    func setProfile(profileInfo: CaregiverProfile) {
        dobLabel.text = profileInfo.dateOfBirth
        genderLabel.text = profileInfo.gender
        nameLabel.text = profileInfo.patientName
        addressLabel.text = profileInfo.patientAddress
        contactLabel.text = profileInfo.patientContact
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProfile(profileInfo: profileData)
    }

    @IBAction func donebutton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 4
        
        default:
            fatalError("Chal")
        }
    }
}
