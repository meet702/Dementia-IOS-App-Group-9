import UIKit

class CaregiverFreeTextViewController: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nextButton: UIButton!

    var startingStep = 6
    var totalSteps = 7

    private let placeholderText = "Add response"
    private let bgColor = UIColor(red: 0.99, green: 0.96, blue: 0.91, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = bgColor

        enableKeyboardDismissOnTap()
        setupUI()
        updateProgress()
        setupPlaceholder()
    }

    private func setupUI() {

        nextButton.layer.cornerRadius = 27
        nextButton.backgroundColor = .systemOrange

        progressView.trackTintColor = .systemGray5
        progressView.progressTintColor = .systemOrange

        textView.backgroundColor = UIColor(white: 0.97, alpha: 1)
        textView.layer.cornerRadius = 14
        textView.layer.borderWidth = 0

        textView.textContainerInset = UIEdgeInsets(
            top: 14,
            left: 12,
            bottom: 14,
            right: 12
        )
    }

    private func updateProgress() {
        progressView.progress = Float(startingStep) / Float(totalSteps)
    }

    private func setupPlaceholder() {
        textView.delegate = self
        textView.text = placeholderText
        textView.textColor = .systemGray2
    }

    @IBAction func nextTapped(_ sender: UIButton) {

        let response = textView.text
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if response.isEmpty || response == placeholderText {
            showAlert("Please add a response.")
            return
        }

        performSegue(withIdentifier: "showCaregiverConnect", sender: nil)
    }

    private func showAlert(_ message: String) {

        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension CaregiverFreeTextViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {

        if textView.textColor == .systemGray2 {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {

        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeholderText
            textView.textColor = .systemGray2
        }
    }
}
