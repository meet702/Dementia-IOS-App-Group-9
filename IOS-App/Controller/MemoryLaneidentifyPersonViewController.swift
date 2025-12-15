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
    var correctAnswer = "Priyamani"
    var selectedAnswer = ""
    var relation: String = "Family"


    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let options = ["Harshita", "Aayushi", "Priyamani", "Purvi"]
        optionOneButton.setTitle(options[0], for: .normal)
        optionTwoButton.setTitle(options[1], for: .normal)
        optionThreeButton.setTitle(options[2], for: .normal)
        optionFourButton.setTitle(options[3], for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let progress = MemorySessionManager.shared.advanceProgress()
        progressView.setProgress(progress, animated: true)
    }
    
    private func setupUI() {
        [optionOneButton, optionTwoButton, optionThreeButton, optionFourButton].forEach {
            $0?.layer.cornerRadius = 20
            $0?.backgroundColor = UIColor(white: 0.95, alpha: 1)
            $0?.layer.borderWidth = 0
        }
        
        // ✅ SET IMAGES
        characterImageView.image = UIImage(named: "image 41")
        groupImageView.image = UIImage(named: "image 40")
        
 
        characterImageView.clipsToBounds = true
        groupImageView.clipsToBounds = true
       
        backGroundView.layer.cornerRadius = 35
        guessButton.setTitle("Guess", for: .normal)
    }
    
    @IBAction func optionTapped(_ sender: UIButton) {
       
        
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
        
        if selectedAnswer == correctAnswer {
            highlightCorrect()
        } else {
            highlightWrong()
        }

        guessButton.setTitle("Next", for: .normal)
    }
    
    
    private func highlightCorrect() {
        MemorySessionManager.shared.setIdentificationResult(correct: true)
        [optionOneButton, optionTwoButton, optionThreeButton, optionFourButton].forEach {
            if $0?.title(for: .normal) == correctAnswer {
                $0?.layer.borderWidth = 3
                $0?.layer.borderColor = UIColor.green.cgColor
                $0?.backgroundColor = UIColor(red: 0.78, green: 1.0, blue: 0.78, alpha: 1)
            }
        }
        guessButton.setTitle("Next", for: .normal)
    }
    
    private func highlightWrong() {
        MemorySessionManager.shared.setIdentificationResult(correct: false)
        [optionOneButton, optionTwoButton, optionThreeButton, optionFourButton].forEach {
            if $0?.title(for: .normal) == selectedAnswer {
                $0?.layer.borderWidth = 3
                $0?.layer.borderColor = UIColor.red.cgColor
                $0?.backgroundColor = UIColor(red: 1.0, green: 0.75, blue: 0.75, alpha: 1)
            }
        }
        
        highlightCorrect()  // show correct also
        guessButton.setTitle("Next", for: .normal)
    }
    
    @IBAction func hintButtonTapped(_ sender: UIButton) {
        let popup = MemoryLaneHintViewController(
            nibName: "MemoryLaneHintViewController",
            bundle: nil
        )
        popup.hintText = "She worked on the Infosys project with you."
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        present(popup, animated: false)
    }

    func moveToNextQuestion() {
        MemorySessionManager.shared.beginSession(
            for: correctAnswer,
            relation: relation
        )
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let nextVC =
            sb.instantiateViewController(
                withIdentifier: "TextQuestion"
            ) as? QuestionResponseViewController {
            
            
            nextVC.personImage = characterImageView.image
            nextVC.groupImage = groupImageView.image
            nextVC.personName = correctAnswer
            nextVC.relation = relation
            
            let selected =
                QuestionBank.shared.getQuestions(for: relation)
            nextVC.questions = selected.text
            nextVC.mcqQuestions = selected.mcq

            navigationController?.pushViewController(
                nextVC,
                animated: true
            )
        }
    }

}
