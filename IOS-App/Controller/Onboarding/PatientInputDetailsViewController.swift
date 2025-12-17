//
//  PatientInputDetailsViewController.swift
//  onboardingScreen
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class PatientInputDetailsViewController: UIViewController {

    // MARK: - IBOutlets (connect these in storyboard)
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var stepLabel: UILabel!

    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!

    @IBOutlet weak var doneButton: UIButton! // connect this but the segue should be triggered in code

    // MARK: - Pickers and data
    private let datePicker = UIDatePicker()
    private let genderPicker = UIPickerView()
    private let genders = ["Male", "Female", "Other", "Prefer not to say"]

    // Progress values
    private let totalStepsFloat: Float = 6
    private var currentStepFloat: Float = 1

    // We'll generate questions dynamically and pass them on segue
    // (keep this function if using dynamic MCQ)
    private func createPatientQuestions() -> [OnboardingQuestions] {
        return [
            OnboardingQuestions(title: "1. What stage of memory loss do you experience?", options: ["Mild","Moderate","Severe","Not sure"], selectionType: .single),
            OnboardingQuestions(title: "2. Do you have difficulty recognizing people?", options: ["Rarely","Sometimes","Often"], selectionType: .single),
            OnboardingQuestions(title: "3. Do you prefer simple or detailed tasks?", options: ["Simple","Moderate","Detailed"], selectionType: .single),
            OnboardingQuestions(title: "4. What relationships matter most to you?", options: ["Children","Siblings","Friends","Spouse","Grandchildren"], selectionType: .multiple),
            OnboardingQuestions(title: "5. What type of memories do you enjoy revisiting?", options: ["Travel","Family gatherings","Festivals","Work life","Childhood","Pets"], selectionType: .multiple)
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        enableKeyboardDismissOnTap()
        configureProgressUI()
        configureFields()
        configureDatePicker()
        configureGenderPicker()
    }

    // MARK: - Progress UI
    private func configureProgressUI() {
        stepLabel.text = "Step \(Int(currentStepFloat)) of \(Int(totalStepsFloat))"
        progressView.progress = currentStepFloat / totalStepsFloat

        // Thicken & round the progress view
        progressView.layer.cornerRadius = 3
        progressView.clipsToBounds = true
        if let last = progressView.layer.sublayers?.last {
            last.cornerRadius = 3
            last.masksToBounds = true
        }
        progressView.trackTintColor = UIColor.systemGray5
        progressView.progressTintColor = UIColor.systemOrange
    }

    // MARK: - Fields & buttons
    private func configureFields() {
        

        doneButton.layer.cornerRadius = 27
        doneButton.clipsToBounds = true
        doneButton.backgroundColor = UIColor.systemOrange
        doneButton.setTitleColor(.white, for: .normal)

        // Hide caret for the picker-backed textfields so user uses pickers
        dobTextField.tintColor = .clear
        genderTextField.tintColor = .clear

        // Right view icons
        let calendarBtn = UIButton(type: .system)
        calendarBtn.setImage(UIImage(systemName: "calendar"), for: .normal)
        calendarBtn.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        calendarBtn.addTarget(self, action: #selector(dobTapped), for: .touchUpInside)
       // dobTextField.rightView = calendarBtn
        dobTextField.rightViewMode = .always

        let chevron = UIImageView(image: UIImage(systemName: "chevron.down"))
        chevron.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        chevron.contentMode = .scaleAspectFit
       // genderTextField.rightView = chevron
        genderTextField.rightViewMode = .always

        // Basic textfield styling
        [fullNameTextField, dobTextField, genderTextField].forEach { tf in
            tf?.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
            tf?.layer.cornerRadius = 10
            tf?.layer.masksToBounds = true
            tf?.setLeftPadding(12)
        }
    }

    // MARK: - Date picker
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

    @objc private func dobTapped() {
        dobTextField.becomeFirstResponder()
    }

    @objc private func dateDone() {
        let df = DateFormatter()
        df.dateStyle = .medium
        dobTextField.text = df.string(from: datePicker.date)
        dobTextField.resignFirstResponder()
        dobTextField.textColor = UIColor.darkGray

    }

    // MARK: - Gender picker
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

    // MARK: - Done action (validate, then perform segue to MCQ)
    @IBAction func doneTapped(_ sender: UIButton) {
        // Validate
        guard let name = fullNameTextField.text, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert("Please enter your full name.")
            return
        }
        guard let _ = dobTextField.text, !(dobTextField.text?.isEmpty ?? true) else {
            showAlert("Please pick your date of birth.")
            return
        }
        guard let _ = genderTextField.text, !(genderTextField.text?.isEmpty ?? true) else {
            showAlert("Please select your gender.")
            return
        }

        // If you set the segue from the view controller to MCQ with identifier "showMCQ", call it:
        performSegue(withIdentifier: "showMCQ", sender: self)
    }

    // MARK: - Prepare for segue (pass data to MCQ)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMCQ",
           let mcqVC = segue.destination as? MCQViewController {

            mcqVC.questions = createPatientQuestions()
            mcqVC.headerTitles = PatientMCQFactory.headers
            mcqVC.startingStep = 2
            mcqVC.totalSteps = 6
        }
    }


    // MARK: - Helper
    private func showAlert(_ msg: String) {
        let a = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - UIPicker delegates
extension PatientInputDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
}

// MARK: - UITextField left padding helper
private extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        leftView = v
        leftViewMode = .always
    }
}
