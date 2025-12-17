//
//  CaregiverInputDetailsViewController.swift
//  onboardingScreen
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class CaregiverInputDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!

    private let fields: [CaregiverInputField] = [
        CaregiverInputField(
            title: "Full Name",
            placeholder: "Enter full name",
            type: .text
        ),
        CaregiverInputField(
            title: "Mobile Number",
            placeholder: "Enter mobile number",
            type: .phone
        ),
        CaregiverInputField(
            title: "Patient’s Address",
            placeholder: "Enter patient's address",
            type: .text
        ),
        CaregiverInputField(
            title: "Relationship with patient",
            placeholder: "Enter relationship",
            type: .text
        ),
        CaregiverInputField(
            title: "Gender",
            placeholder: "Select gender",
            type: .picker
        )
    ]

    private var inputValues: [Int: String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        enableKeyboardDismissOnTap()
        setupTableView()
        setupButton()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = UITableView.automaticDimension
    }
    

    private func setupButton() {
        nextButton.layer.cornerRadius = 28
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        print("NEXT BUTTON TAPPED")
            view.endEditing(true)

            for index in 0..<fields.count {
                if inputValues[index]?.isEmpty ?? true {
                    print("Missing field at index \(index)")
                    return
                }
            }

            print("Validation passed, performing segue")
            performSegue(withIdentifier: "showCaregiverMCQ", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCaregiverMCQ" {
            let mcqVC = segue.destination as! CaregiverMCQViewController

            mcqVC.questions = CaregiverMCQFactory.makeQuestions()
            mcqVC.startingStep = 2
            mcqVC.totalSteps = 7
            mcqVC.headerTitles = CaregiverMCQFactory.headers
        }
    }

}


extension CaregiverInputDetailsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "InputCell",
            for: indexPath
        ) as? InputCell else {
            return UITableViewCell()
        }

        let field = fields[indexPath.row]

        cell.configure(
            title: field.title,
            placeholder: field.placeholder
        )
        cell.textField.inputView = nil
        cell.textField.rightView = nil


        switch field.type {
        case .text:
            cell.textField.keyboardType = .default

        case .phone:
            cell.textField.keyboardType = .phonePad

        case .picker:
            cell.enableGenderPicker()
        }

        cell.onTextChanged = { [weak self] text in
            self?.inputValues[indexPath.row] = text
        }

        return cell
    }
}

