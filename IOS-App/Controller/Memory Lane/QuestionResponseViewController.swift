import UIKit

class QuestionResponseViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var progressView: UIProgressView!

    var questions: [Question] = []
    var mcqQuestions: [Question] = []
    private var currentIndex: Int = 0

    var groupImage: UIImage?
    var personImage: UIImage?
    var personName: String = ""
    var relation: String = ""
    var personIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        personImageView.image = personImage
        personImageView.clipsToBounds = true
        personNameLabel.text = personName

        responseTextView.delegate = self
        setupUI()


        loadQuestion()
        progressView.progress = MemorySessionManager.shared.currentProgress()
    }

    private func setupUI() {
        backgroundView.layer.cornerRadius = 35

        responseTextView.layer.cornerRadius = 20
        responseTextView.layer.borderWidth = 1.5
        responseTextView.layer.borderColor =
            UIColor(white: 0.85, alpha: 1).cgColor

        responseTextView.textContainerInset =
            UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)

        nextButton.layer.cornerRadius = 26
        
        nextButton.isEnabled = false
        nextButton.alpha = 0.4

    }

    private func loadQuestion() {
        guard currentIndex < questions.count else { return }

        let q = questions[currentIndex]
        questionLabel.text = q.question
        responseTextView.text = q.placeholder ?? "Add response"
        responseTextView.textColor = .lightGray
        responseTextView.resignFirstResponder()
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {

        guard currentIndex < questions.count else {
            goToMCQScreen()
            return
        }

        let rawText =
            responseTextView.textColor == .lightGray
            ? ""
            : (responseTextView.text ?? "")

        MemorySessionManager.shared.addTextAnswer(
            question: questions[currentIndex].question,
            answer: rawText
        )

        let progress = MemorySessionManager.shared.advanceProgress()
        progressView.setProgress(progress, animated: false)

        currentIndex += 1

        if currentIndex < questions.count {
            loadQuestion()
        } else {
            goToMCQScreen()
        }
    }

    private func goToMCQScreen() {
        let sb = UIStoryboard(name: "MemoryLane", bundle: nil)

        guard let mcqVC =
            sb.instantiateViewController(withIdentifier: "mcqVC")
                as? MemoryLaneChoiceQuestionViewController else { return }

        mcqVC.personImage = personImage
        mcqVC.personName = personName
        mcqVC.relation = relation
        mcqVC.mcqQuestions = mcqQuestions
        mcqVC.groupImage = groupImage
        mcqVC.personIndex = personIndex

        navigationController?.pushViewController(mcqVC, animated: false)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty {
            textView.text = "Add response"
            textView.textColor = .lightGray
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        let hasText =
            !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            textView.textColor != .lightGray

        nextButton.isEnabled = hasText
        nextButton.alpha = hasText ? 1.0 : 0.4
    }

}
