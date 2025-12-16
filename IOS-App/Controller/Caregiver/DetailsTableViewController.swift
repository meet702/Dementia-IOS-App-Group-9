//
//  DetailsTableViewController.swift
//  IOS-App
//
//  Created by SDC-USER on 16/12/25.
//

import UIKit
import CoreData

class DetailsTableViewController: UITableViewController {

    var person: PeopleModel!
    private var personEntity: PersonEntity!

    private var selectedRelation: String?

    @IBOutlet weak var relationButton: UIButton!
    @IBOutlet weak var hintTextField: UITextField!
    @IBOutlet weak var detailsTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsSelection = false
        
        fetchPersonEntity()
        configureRelationMenu()
        populateUI()
    }

    private func fetchPersonEntity() {
        let context = PersistenceController.shared.context
        personEntity = context.object(with: person.objectID) as? PersonEntity
    }

    private func populateUI() {

        // Relation
        if let savedRelation = personEntity.relation {
            selectedRelation = savedRelation
            setRelationTitle(for: savedRelation)
        } else {
            relationButton.setTitle("Select relation", for: .normal)
        }
        
        hintTextField.text = personEntity.memoryHint
        detailsTextView.text = personEntity.details
    }

    private func configureRelationMenu() {

        let family = UIAction(title: "Family") { _ in
            self.updateRelation("family")
        }

        let friend = UIAction(title: "Friend") { _ in
            self.updateRelation("friend")
        }

        let work = UIAction(title: "Work") { _ in
            self.updateRelation("work")
        }

        let menu = UIMenu(title: "", children: [family, friend, work])

        relationButton.menu = menu
        relationButton.showsMenuAsPrimaryAction = true
    }

    private func updateRelation(_ value: String) {
        selectedRelation = value
        setRelationTitle(for: value)
    }

    private func setRelationTitle(for value: String) {
        switch value {
        case "family":
            relationButton.setTitle("Family", for: .normal)
        case "friend":
            relationButton.setTitle("Friend", for: .normal)
        case "work":
            relationButton.setTitle("Work", for: .normal)
        default:
            relationButton.setTitle("Select relation", for: .normal)
        }
    }

    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        // ❌ Discard changes
        dismiss(animated: true)
    }

    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        personEntity.relation = selectedRelation
        personEntity.memoryHint = hintTextField.text
        personEntity.details = detailsTextView.text

        do {
            try PersistenceController.shared.context.save()
            print("✅ Person details saved")
            dismiss(animated: true)
        } catch {
            print("❌ Failed to save person details:", error)
        }
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
