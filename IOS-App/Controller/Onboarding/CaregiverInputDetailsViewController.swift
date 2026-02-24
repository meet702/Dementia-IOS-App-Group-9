import UIKit

class CaregiverInputDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!

    private let fields: [InputField] = [
        InputField(title: "Full Name", placeholder: "Enter full name", type: .text),
        InputField(title: "Mobile Number", placeholder: "Enter mobile number", type: .phone),
        InputField(title: "Patient's Address", placeholder: "Enter patient's address", type: .text),
        InputField(title: "Relationship with patient", placeholder: "Enter relationship", type: .text),
        InputField(title: "Gender", placeholder: "Select gender", type: .picker)
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

        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = UITableView.automaticDimension
    }

    private func setupButton() {
        nextButton.layer.cornerRadius = 27
        nextButton.backgroundColor = .systemOrange
        nextButton.setTitleColor(.white, for: .normal)
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        view.endEditing(true)

        for index in 0..<fields.count {
            if inputValues[index]?.trimmingCharacters(in: .whitespaces).isEmpty ?? true {
                showAlert("Please fill all fields")
                return
            }
        }

        performSegue(withIdentifier: "showCaregiverMCQ", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCaregiverMCQ",
           let mcqVC = segue.destination as? CaregiverMCQViewController {

            mcqVC.questions = OnboardingQuestionBank.caregiverQuestions()
            mcqVC.headerTitles = OnboardingQuestionBank.caregiverHeaders
            mcqVC.startingStep = 2
            mcqVC.totalSteps = 7
        }
    }

    private func showAlert(_ msg: String) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension CaregiverInputDetailsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fields.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "InputCell",
            for: indexPath
        ) as? InputCell else { return UITableViewCell() }

        let field = fields[indexPath.row]

        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear

        cell.configure(title: field.title, placeholder: field.placeholder)

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
