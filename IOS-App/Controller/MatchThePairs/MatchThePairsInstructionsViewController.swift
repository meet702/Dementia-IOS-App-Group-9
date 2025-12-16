//
//  MatchThePairsViewController.swift
//  brainboosters
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class MatchThePairsInstructionsViewController: UIViewController {

    @IBOutlet weak var howToPlayView: UIView!
    @IBOutlet weak var instructionsCard: UIView!
    @IBOutlet weak var howToPlayChevronButton: UIButton!
    @IBOutlet weak var easyCard: UIView!
    @IBOutlet weak var mediumCard: UIView!
    @IBOutlet weak var hardCard: UIView!

    var isHowToPlayOpen = false

    // --- NEW: Track selected difficulty ---
    enum Difficulty {
        case easy, medium, hard
    }
    private var selectedDifficulty: Difficulty? {
        didSet {
            // You can add additional side-effects here if needed
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Game VC viewDidAppear")
        instructionsCard.isHidden = true  // start closed
        howToPlayChevronButton.isUserInteractionEnabled = false

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

        // selected background + border
        let selectedBackground = UIColor(red: 1.0, green: 0.75, blue: 0.46, alpha: 0.25)
        let selectedBorder = UIColor(red: 0.95, green: 0.6, blue: 0.2, alpha: 1.0).cgColor

        for c in cards {
            let isSelected = (c === card)

            if isSelected {
                animateCardTransition(card: c!,
                                      toColor: selectedBackground,
                                      borderColor: UIColor(red: 0.95, green: 0.6, blue: 0.2, alpha: 1))
            } else {
                animateCardTransition(card: c!,
                                      toColor: .white,
                                      borderColor: nil)
            }

            c?.layer.borderWidth = isSelected ? 2 : 0
            c?.layer.borderColor = isSelected ? selectedBorder : UIColor.clear.cgColor
            c?.layer.cornerRadius = 20
        }
    }

    // -------------------------
    // MARK: - Actions
    // -------------------------

    @IBAction func howToPlayTapped(_ sender: Any) {
        isHowToPlayOpen.toggle()   // flip true/false

        // Change chevron direction
        let imageName = isHowToPlayOpen ? "chevron.up" : "chevron.down"
        howToPlayChevronButton.setImage(UIImage(systemName: imageName), for: .normal)

        // Animate the card appearing / disappearing
        UIView.animate(withDuration: 0.25) {
            self.instructionsCard.isHidden = !self.isHowToPlayOpen
            self.view.layoutIfNeeded()   // stack view smoothly moves everything
        }
    }

    // NOTE: keeping your existing IBAction names — they now set selectedDifficulty
    @IBAction func easyCardTapped(_ sender: Any) {
        print("easy tapped")
        selectedDifficulty = .easy
        selectDifficulty(card: easyCard)
    }

    @IBAction func mediumCardTapped(_ sender: Any) {
        print("medium tapped")
        selectedDifficulty = .medium
        selectDifficulty(card: mediumCard)
    }

    @IBAction func hardCardTapped(_ sender: Any) {
//        print("hard tapped")
        selectedDifficulty = .hard
        selectDifficulty(card: hardCard)
    }

    @IBAction func playTapped(_ sender: UIButton) {
        print("playTapped called")
        // ensure a difficulty is selected before starting
        guard selectedDifficulty != nil else {
            let alert = UIAlertController(title: "Select Difficulty",
                                          message: "Please choose Easy, Medium, or Hard before playing.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        // perform a single segue to start the game
        performSegue(withIdentifier: "startGame", sender: self)
    }

    // Pass rows/columns based on the selected difficulty
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
