import UIKit
import Supabase

class PatientInputDetailsViewController: UIViewController {

    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!

    private let datePicker = UIDatePicker()
    private let genderPicker = UIPickerView()
    private let genders = ["Male", "Female", "Other", "Prefer not to say"]

    private let totalStepsFloat: Float = 6
    private var currentStepFloat: Float = 1
    var verifiedEmail: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.99, green: 0.96, blue: 0.91, alpha: 1)
        enableKeyboardDismissOnTap()
        configureFields()
        configureDatePicker()
        configureGenderPicker()
    }

    private func configureFields() {
        doneButton.layer.cornerRadius = 27
        doneButton.clipsToBounds = true
        doneButton.backgroundColor = UIColor.systemOrange
        doneButton.setTitleColor(.white, for: .normal)

        dobTextField.tintColor = .clear
        genderTextField.tintColor = .clear

        let calendarBtn = UIButton(type: .system)
        calendarBtn.setImage(UIImage(systemName: "chevron.up.chevron.down"), for: .normal)
        calendarBtn.tintColor = .systemGray3
        calendarBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        calendarBtn.addTarget(self, action: #selector(dobTapped), for: .touchUpInside)
        dobTextField.rightView = calendarBtn
        dobTextField.rightViewMode = .always

        let genderChevron = UIButton(type: .system)
        genderChevron.setImage(UIImage(systemName: "chevron.up.chevron.down"), for: .normal)
        genderChevron.tintColor = .systemGray3
        genderChevron.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        genderChevron.addTarget(self, action: #selector(genderTapped), for: .touchUpInside)
        genderTextField.rightView = genderChevron
        genderTextField.rightViewMode = .always

        [fullNameTextField, dobTextField, genderTextField].forEach { tf in
            tf?.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
            tf?.layer.cornerRadius = 10
            tf?.layer.masksToBounds = true
            tf?.setLeftPadding(12)
        }
    }

    private func configureDatePicker() {
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        dobTextField.inputView = datePicker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .prominent, target: self, action: #selector(dateDone))
        toolbar.setItems([flex, done], animated: false)
        dobTextField.inputAccessoryView = toolbar
    }

    @objc private func dobTapped() { dobTextField.becomeFirstResponder() }
    @objc private func genderTapped() { genderTextField.becomeFirstResponder() }

    @objc private func dateDone() {
        let df = DateFormatter()
        df.dateStyle = .medium
        dobTextField.text = df.string(from: datePicker.date)
        dobTextField.resignFirstResponder()
        dobTextField.textColor = UIColor.darkGray
    }

    private func configureGenderPicker() {
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderTextField.inputView = genderPicker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .prominent, target: self, action: #selector(genderDone))
        toolbar.setItems([flex, done], animated: false)
        genderTextField.inputAccessoryView = toolbar
    }

    @objc private func genderDone() {
        let row = genderPicker.selectedRow(inComponent: 0)
        genderTextField.text = genders[row]
        genderTextField.resignFirstResponder()
        genderTextField.textColor = UIColor.darkGray
    }

    @IBAction func doneTapped(_ sender: UIButton) {
        guard let name = fullNameTextField.text, !name.isEmpty else { showAlert("Enter full name"); return }
        guard let dob = dobTextField.text, !dob.isEmpty else { showAlert("Select date of birth"); return }
        guard let gender = genderTextField.text, !gender.isEmpty else { showAlert("Select gender"); return }

        SessionManager.shared.patientName = name
        doneButton.isEnabled = false

        createPatientProfile(name: name, gender: gender, dob: dob)
    }

    private func createPatientProfile(name: String, gender: String, dob: String) {
        guard let uid = SupabaseManager.shared.client.auth.currentUser?.id else {
            showAlert("Session expired. Please log in again.")
            doneButton.isEnabled = true
            return
        }

        let profile = UserProfile(
            uid: uid,
            name: name,
            email: verifiedEmail,
            role: .patient,
            gender: gender,
            caregiverUid: nil,
            createdAt: Date(),
            dob: dob
        )

        Task {
            do {
                try await SupabaseSyncManager.shared.createUserProfile(profile)
                SessionManager.shared.currentUserProfile = profile
                await MainActor.run {
                    self.performSegue(withIdentifier: "goToHomeScreen", sender: nil)
                }
            } catch {
                await MainActor.run {
                    self.doneButton.isEnabled = true
                    self.showAlert(error.localizedDescription)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToHomeScreen",
           let homeVC = segue.destination as? HomeViewController {

        }
    }

    private func showAlert(_ msg: String) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension PatientInputDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { genders.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { genders[row] }
}

private extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 1))
        leftViewMode = .always
    }
}
