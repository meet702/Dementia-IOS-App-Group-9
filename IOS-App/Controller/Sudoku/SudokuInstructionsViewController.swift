//
//  SudokuViewController.swift
//  sudoku
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class SudokuInstructionsViewController: UIViewController {

    @IBOutlet weak var instructionsCard: UIView!
    
    @IBOutlet weak var howToPlayChevronButton: UIButton!
    @IBOutlet weak var easyCard: UIView!
   
    @IBOutlet weak var howToPlayView: UIView!
    
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
        instructionsCard.isHidden = true  // start closed
        howToPlayChevronButton.isUserInteractionEnabled = false
        setupInstructionsText()
        let cards = [easyCard, mediumCard, hardCard, howToPlayView, instructionsCard]
        for card in cards {
            card?.backgroundColor = UIColor.white
            card?.layer.cornerRadius = 20
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
        let selectedBorder = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0).cgColor

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
    
    private func setupInstructionsText() {
        let text = """
        1. Select a cell and tap a number to fill it
        2. Use Undo to remove the last move
        3. Use Erase to clear a cell
        4. Tap Check to verify a number
        5. Use Hint to reveal the correct number
        """

        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 12
        paragraphStyle.paragraphSpacing = 8

        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .paragraphStyle: paragraphStyle,
                
            ]
        )

        instructionsLabel.attributedText = attributedText
    }


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
        print("hard tapped")
        selectedDifficulty = .hard
        selectDifficulty(card: hardCard)
    }

    @IBAction func playTapped(_ sender: UIButton) {
        print("playTapped called")
        guard selectedDifficulty != nil else {
            let alert = UIAlertController(title: "Select Difficulty",
                                          message: "Please choose Easy, Medium, or Hard before playing.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSudoku" {
                let dest = segue.destination as! SudokuViewController

                // easy
                if selectedDifficulty == .easy {
                    dest.difficultyLevel = 1
                }

                // medium
                else if selectedDifficulty == .medium {
                    dest.difficultyLevel = 2
                }

                // hard
                else if selectedDifficulty == .hard {
                    dest.difficultyLevel = 3
                }
            }
    }
}

