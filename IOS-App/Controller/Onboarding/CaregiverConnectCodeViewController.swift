import UIKit

class CaregiverConnectCodeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var finishButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        enableKeyboardDismissOnTap()
        setupUI()
    }

    // MARK: UI


    private func setupUI() {


        finishButton.layer.cornerRadius = 27
        codeTextField.layer.cornerRadius = 24
        codeTextField.keyboardType = .numberPad
        //codeTextField.setLeftPadding(12)

        codeTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter connection code",
            attributes: [
                .foregroundColor: UIColor.systemGray3,
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
    }


    // MARK: Actions

    @IBAction func finishTapped(_ sender: UIButton) {

        let code = codeTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !code.isEmpty else {
            showAlert("Please enter the connection code.")
            return
        }

        // Later → Save connection code to Caregiver Profile

        performSegue(withIdentifier: "goToCaregiverHome", sender: nil)
    }

    // MARK: Alert

    private func showAlert(_ message: String) {

        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: Padding Helper

private extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 1))
        leftView = view
        leftViewMode = .always
    }
}
