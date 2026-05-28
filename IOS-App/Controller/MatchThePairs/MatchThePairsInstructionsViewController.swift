import UIKit

class MatchThePairsInstructionsViewController: UIViewController {

    @IBOutlet weak var howToPlayView: UIView!
    @IBOutlet weak var instructionsCard: UIView!
    @IBOutlet weak var howToPlayChevronButton: UIButton!
    @IBOutlet weak var easyCard: UIView!
    @IBOutlet weak var mediumCard: UIView!
    @IBOutlet weak var hardCard: UIView!
    @IBOutlet weak var instructionsLabel: UILabel!

    var isHowToPlayOpen = false

    enum Difficulty {
        case easy, medium, hard
    }
    private var selectedDifficulty: Difficulty? {
        didSet {
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        instructionsCard.isHidden = true
        howToPlayChevronButton.isUserInteractionEnabled = false

        setupInstructionsText()
        let cards = [easyCard, mediumCard, hardCard, howToPlayView, instructionsCard]
        for card in cards {
            card?.backgroundColor = UIColor.white
            card?.layer.cornerRadius = 20
            card?.layer.borderWidth = 0
            card?.layer.borderColor = UIColor.clear.cgColor
        }
    }

    func animateCardTransition(card: UIView, toColor: UIColor, borderColor: UIColor?) {
        UIView.transition(with: card,
                          duration: 0.35,
                          options: [.transitionCrossDissolve, .allowAnimatedContent],
                          animations: {

            card.backgroundColor = toColor

            if let borderColor = borderColor {
                card.layer.borderColor = borderColor.cgColor
                card.layer.borderWidth = 2
            } else {
                card.layer.borderWidth = 0
            }
        }, completion: nil)
    }

    func selectDifficulty(card: UIView) {
        let cards = [easyCard, mediumCard, hardCard]

        let selectedBackground = UIColor(red: 1.0, green: 0.75, blue: 0.46, alpha: 0.25)
        let selectedBorder = UIColor(red: 0.95, green: 0.6, blue: 0.2, alpha: 1.0).cgColor

        for c in cards {
            guard let cardToAnimate = c else { continue }
            let isSelected = (cardToAnimate === card)

            if isSelected {
                animateCardTransition(card: cardToAnimate,
                                      toColor: selectedBackground,
                                      borderColor: UIColor(red: 0.95, green: 0.6, blue: 0.2, alpha: 1))
            } else {
                animateCardTransition(card: cardToAnimate,
                                      toColor: .white,
                                      borderColor: nil)
            }

            cardToAnimate.layer.borderWidth = isSelected ? 2 : 0
            cardToAnimate.layer.borderColor = isSelected ? selectedBorder : UIColor.clear.cgColor
            cardToAnimate.layer.cornerRadius = 20
        }
    }

    @IBAction func howToPlayTapped(_ sender: Any) {
        isHowToPlayOpen.toggle()

        let imageName = isHowToPlayOpen ? "chevron.up" : "chevron.down"
        howToPlayChevronButton.setImage(UIImage(systemName: imageName), for: .normal)

        UIView.animate(withDuration: 0.25) {
            self.instructionsCard.isHidden = !self.isHowToPlayOpen
            self.view.layoutIfNeeded()
        }
    }

    private func setupInstructionsText() {
        let text = """
        1. Tap two cards at a time.
        2. If the cards match, they will stay open.
        3. Try to find all the pairs.
        4. No rush, take your time.
        """

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        paragraphStyle.paragraphSpacing = 6

        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .paragraphStyle: paragraphStyle

            ]
        )

        instructionsLabel.attributedText = attributedText
    }

    @IBAction func easyCardTapped(_ sender: Any) {
        selectedDifficulty = .easy
        selectDifficulty(card: easyCard)
    }

    @IBAction func mediumCardTapped(_ sender: Any) {
        selectedDifficulty = .medium
        selectDifficulty(card: mediumCard)
    }

    @IBAction func hardCardTapped(_ sender: Any) {
        selectedDifficulty = .hard
        selectDifficulty(card: hardCard)
    }

    @IBAction func playTapped(_ sender: UIButton) {
        guard selectedDifficulty != nil else {
            let alert = UIAlertController(title: "Select Difficulty",
                                          message: "Please choose Easy, Medium, or Hard before playing.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        performSegue(withIdentifier: "startGame", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startGame",
           let dest = segue.destination as? MatchThePairsViewController {

            switch selectedDifficulty {
            case .easy:
                dest.columns = 3; dest.rows = 4
            case .medium:
                dest.columns = 3; dest.rows = 6
            case .hard:
                dest.columns = 4; dest.rows = 6
            case .none:
                break
            }
        }
    }
}
