import UIKit

class CaregiverInputDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!

    private let fields: [InputField] = [
        InputField(title: "Full Name", placeholder: "Enter full name", type: .text),
        InputField(title: "Relationship with patient", placeholder: "Enter relationship", type: .text),
        InputField(title: "Gender", placeholder: "Select gender", type: .picker)
    ]

    private var inputValues: [Int: String] = [:]
    private var cachedCells: [Int: InputCell] = [:]
    var verifiedPhone: String = ""

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

        guard let name = inputValues[0]?.trimmingCharacters(in: .whitespaces), !name.isEmpty,
              let relationship = inputValues[1]?.trimmingCharacters(in: .whitespaces), !relationship.isEmpty,
              let gender = inputValues[2]?.trimmingCharacters(in: .whitespaces), !gender.isEmpty else {
            showAlert("Please fill all fields")
            return
        }

        SessionManager.shared.caregiverName = name
        SessionManager.shared.caregiverGender = gender
        SessionManager.shared.caregiverRelation = relationship

        performSegue(withIdentifier: "showCaregiverConnect", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCaregiverConnect",
           let mcqVC = segue.destination as? CaregiverConnectCodeViewController {
            mcqVC.verifiedPhone = verifiedPhone          // ✅ pass forward
            mcqVC.caregiverName = inputValues[0] ?? ""   // ✅ index 0 is Full Name
            mcqVC.caregiverRelation = inputValues[1] ?? ""
            mcqVC.caregiverGender = inputValues[2] ?? ""
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let row = indexPath.row

        // Return cached cell if it exists
        if let cached = cachedCells[row] { return cached }

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "InputCell",
            for: indexPath
        ) as? InputCell else { return UITableViewCell() }

        let field = fields[row]
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
            self?.inputValues[row] = text
        }

        // Cache it so it's never reused
        cachedCells[row] = cell
        return cell
    }
}
