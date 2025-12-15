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
    var currentIndex: Int = 0

    var groupImage: UIImage?
    var personImage: UIImage?
    var personName: String = ""
    var relation: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        personImageView.image = personImage
        personImageView.clipsToBounds = true   

        personNameLabel.text = personName

        MemorySessionManager.shared.beginSession(
            for: personName,
            relation: relation
        )

        responseTextView.delegate = self
        setupUI()
        loadQuestion()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let progress = MemorySessionManager.shared.advanceProgress()
        progressView.setProgress(progress, animated: true)
    }

    private func setupUI() {
        backgroundView.layer.cornerRadius = 35

        responseTextView.layer.cornerRadius = 20
        responseTextView.layer.borderWidth = 1.5
        responseTextView.layer.borderColor =
            UIColor(white: 0.85, alpha: 1).cgColor

        responseTextView.textContainerInset =
            UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }

    private func loadQuestion() {
        let q = questions[currentIndex]
        questionLabel.text = q.question
        responseTextView.text = q.placeholder ?? "Add response"
        responseTextView.textColor = .lightGray
        responseTextView.resignFirstResponder()
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {

        let rawText =
            (responseTextView.textColor == .lightGray)
            ? ""
            : (responseTextView.text ?? "")

        MemorySessionManager.shared.addTextAnswer(
            question: questions[currentIndex].question,
            answer: rawText
        )

        currentIndex += 1

        if currentIndex < questions.count {
            loadQuestion()
        } else {
            goToMCQScreen()
        }
    }

    private func goToMCQScreen() {
        let sb = UIStoryboard(name: "Main", bundle: nil)

        if let mcqVC =
            sb.instantiateViewController(withIdentifier: "mcqVC")
                as? MemoryLaneChoiceQuestionViewController {

            mcqVC.personImage = personImage
            mcqVC.personName = personName
            mcqVC.relation = relation
            mcqVC.mcqQuestions = mcqQuestions
            mcqVC.groupImage = groupImage
            navigationController?.pushViewController(mcqVC, animated: false)
        }
    }


    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "Add response"
            textView.textColor = .lightGray
        }
    }
}
