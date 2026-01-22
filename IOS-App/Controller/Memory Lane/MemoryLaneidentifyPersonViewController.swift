import UIKit

class MemoryLaneidentifyPersonViewController: UIViewController {
    
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var characterImageView: UIImageView!
    
    @IBOutlet weak var optionOneButton: UIButton!
    @IBOutlet weak var optionTwoButton: UIButton!
    @IBOutlet weak var optionThreeButton: UIButton!
    @IBOutlet weak var optionFourButton: UIButton!
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var guessButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!

    var correctAnswer: String = ""
    var selectedAnswer = ""
    var relation: String = "Family"
    var personIndex: Int = 0

    private let relationByPerson: [String: String] = [
        "Priyamani": "Family",
        "Priyadarshan": "Friends",
        "Priya": "Work"
    ]

    private let imageByPerson: [String: String] = [
        "Priyamani": "image_41",
        "Priyadarshan": "image_39",
        "Priya": "image_42"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        var options: [String] = []

        if let imageSession = MemorySessionManager.shared.currentImageSession {
            let people = imageSession.peopleShown

            if personIndex < people.count {
                correctAnswer = people[personIndex]
                relation = relationByPerson[correctAnswer] ?? "Family"
            }

            options = people.shuffled()
        }

        if options.count < 4 {
            options.append(contentsOf: ["Harshita", "Aayushi", "Purvi"])
            options = Array(options.prefix(4))
        }

        setupUI()

        optionOneButton.setTitle(options[0], for: .normal)
        optionTwoButton.setTitle(options[1], for: .normal)
        optionThreeButton.setTitle(options[2], for: .normal)
        optionFourButton.setTitle(options[3], for: .normal)

        selectedAnswer = ""
        progressView.progress = MemorySessionManager.shared.currentProgress()
        restoreIfAlreadyAnswered()
    }

    private func setupUI() {

        if let imageName = imageByPerson[correctAnswer] {
            characterImageView.image = UIImage(named: imageName)
        }

        groupImageView.image = UIImage(named: "image_40")

        characterImageView.clipsToBounds = true
        groupImageView.clipsToBounds = true

        backGroundView.layer.cornerRadius = 35
        guessButton.setTitle("Guess", for: .normal)
    }
    
    @IBAction func optionTapped(_ sender: UIButton) {
        guard guessButton.title(for: .normal) == "Guess" else { return }
        [optionOneButton, optionTwoButton, optionThreeButton, optionFourButton].forEach {
            $0?.backgroundColor = UIColor(white: 0.95, alpha: 1)
            $0?.layer.borderWidth = 0
        }
        
        sender.layer.borderWidth = 3
        sender.layer.borderColor = UIColor.orange.cgColor
        sender.backgroundColor =
            UIColor(red: 1.0, green: 0.88, blue: 0.70, alpha: 1.0)
        
        selectedAnswer = sender.title(for: .normal) ?? ""
    }
    
    @IBAction func guessButtonTapped(_ sender: UIButton) {
        guard selectedAnswer != "" else { return }
        
        if guessButton.title(for: .normal) == "Next" {
            moveToNextQuestion()
            return
        }
        MemorySessionManager.shared.currentSession?.selectedIdentificationAnswer = selectedAnswer

        if selectedAnswer == correctAnswer {
            highlightCorrect()
        } else {
            highlightWrong()
        }

        let progress = MemorySessionManager.shared.advanceProgress()
        progressView.setProgress(progress, animated: false)

        guessButton.setTitle("Next", for: .normal)
    }
    
    private func highlightCorrect() {
        MemorySessionManager.shared.setIdentificationResult(correct: true)
        [optionOneButton, optionTwoButton, optionThreeButton, optionFourButton].forEach {
            if $0?.title(for: .normal) == correctAnswer {
                $0?.layer.borderWidth = 3
                $0?.layer.borderColor = UIColor.green.cgColor
                $0?.backgroundColor =
                    UIColor(red: 0.78, green: 1.0, blue: 0.78, alpha: 1)
            }
        }
    }
    
    private func highlightWrong() {
        MemorySessionManager.shared.setIdentificationResult(correct: false)
        [optionOneButton, optionTwoButton, optionThreeButton, optionFourButton].forEach {
            if $0?.title(for: .normal) == selectedAnswer {
                $0?.layer.borderWidth = 3
                $0?.layer.borderColor = UIColor.red.cgColor
                $0?.backgroundColor =
                    UIColor(red: 1.0, green: 0.75, blue: 0.75, alpha: 1)
            }
        }
        
        highlightCorrect()
    }
    
    @IBAction func hintButtonTapped(_ sender: UIButton) {
        let hintsByPerson: [String: [String]] = [
            "Priyamani": [
                "You meet her during family occasions."
            ],
            "Priyadarshan": [
                "You’ve had friendly conversations with him.",
            ],
            "Priya": [
                "You’ve collaborated on tasks together."
            ]
        ]

        let hints = hintsByPerson[correctAnswer] ?? ["Think about your relationship with them."]
        let randomHint = hints.randomElement() ?? ""

        let popup = MemoryLaneHintViewController(
            nibName: "MemoryLaneHintViewController",
            bundle: nil
        )
        popup.hintText = randomHint
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        present(popup, animated: false)
    }

    func moveToNextQuestion() {
        MemorySessionManager.shared.beginSession(
            for: correctAnswer,
            relation: relation
        )

        let sb = UIStoryboard(name: "MemoryLane", bundle: nil)
        if let nextVC =
            sb.instantiateViewController(
                withIdentifier: "TextQuestion"
            ) as? QuestionResponseViewController {

            nextVC.personImage = characterImageView.image
            nextVC.groupImage = groupImageView.image
            nextVC.personName = correctAnswer
            nextVC.relation = relation
            nextVC.personIndex = personIndex

            let selected =
                QuestionBank.shared.getQuestions(for: relation)
            nextVC.questions = selected.text
            nextVC.mcqQuestions = selected.mcq

            navigationController?.pushViewController(
                nextVC,
                animated: false
            )
        }
    }
    private func restoreIfAlreadyAnswered() {
        guard
            let imageSession = MemorySessionManager.shared.currentImageSession,
            personIndex < imageSession.personSessions.count
        else { return }

        let previousSession = imageSession.personSessions[personIndex]

        guard
            let selected = previousSession.selectedIdentificationAnswer,
            let wasCorrect = previousSession.wasIdentifiedCorrectly
        else { return }

        // Lock buttons
        let buttons = [
            optionOneButton,
            optionTwoButton,
            optionThreeButton,
            optionFourButton
        ]

        buttons.forEach { $0?.isEnabled = false }
        guessButton.isEnabled = false

        // Highlight selected answer
        for button in buttons {
            guard button?.title(for: .normal) == selected else { continue }

            button?.layer.borderWidth = 3
            button?.layer.borderColor =
                wasCorrect ? UIColor.green.cgColor : UIColor.red.cgColor

            button?.backgroundColor =
                wasCorrect
                ? UIColor(red: 0.78, green: 1.0, blue: 0.78, alpha: 1)
                : UIColor(red: 1.0, green: 0.75, blue: 0.75, alpha: 1)
        }

        guessButton.setTitle("Next", for: .normal)
    }

}
