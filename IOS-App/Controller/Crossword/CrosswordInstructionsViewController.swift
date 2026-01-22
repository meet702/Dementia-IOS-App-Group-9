//
//  CrosswordInstructionsViewController.swift
//  IOS-App
//
//

import UIKit

class CrosswordInstructionsViewController: UIViewController {

    @IBOutlet weak var countriesCard: UIView!
    @IBOutlet weak var dailyObjectsCard: UIView!
    @IBOutlet weak var gkCard: UIView!
    @IBOutlet weak var foodCard: UIView!
    @IBOutlet weak var randomCategoryCard: UIView!

    @IBOutlet weak var howToPlayChevronButton: UIButton!
    @IBOutlet weak var howToPlayView: UIView!
    @IBOutlet weak var instructionsCard: UIView!
    @IBOutlet weak var instructionsLabel: UILabel!

    @IBOutlet weak var playButton: UIButton!

    var isHowToPlayOpen = false
    private var selectedCard: UIView?
    private var selectedCategory: CrosswordCategory?
    private var isRandomCategorySelected = false

    // Color styles
    private let selectedBackground = UIColor(red: 1, green: 0.75, blue: 0.46, alpha: 0.25)
    private let selectedBorderColor = UIColor(red: 1, green: 0.6, blue: 0.2, alpha: 1)
    private let unselectedBackground = UIColor.white

    private var allCards: [UIView] {
        return [
            countriesCard, dailyObjectsCard, gkCard, foodCard, randomCategoryCard,
            instructionsCard, howToPlayView
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        instructionsCard.isHidden = true
        howToPlayChevronButton.isUserInteractionEnabled = false

        playButton.isEnabled = false
        playButton.alpha = 0.5

        setupInstructionsText()

        // Style cards
        for card in allCards {
            card.layer.cornerRadius = 20
            card.backgroundColor = unselectedBackground
            card.layer.borderWidth = 0
            card.clipsToBounds = true
        }
    }

    func applyRandomCardUnselectedStyle() {
        guard let card = randomCategoryCard else { return }

        card.layer.sublayers?.removeAll(where: { $0.name == "RandomDashedBorder" })

        let dashed = CAShapeLayer()
        dashed.name = "RandomDashedBorder"
        dashed.frame = card.bounds

        dashed.path = UIBezierPath(
            roundedRect: card.bounds,
            cornerRadius: card.layer.cornerRadius
        ).cgPath

        dashed.strokeColor = UIColor.orange.cgColor
        dashed.lineWidth = 2
        dashed.lineDashPattern = [6, 4]
        dashed.fillColor = UIColor.clear.cgColor

        card.layer.addSublayer(dashed)
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let radius = randomCategoryCard.bounds.height / 2
        randomCategoryCard.layer.cornerRadius = radius
        randomCategoryCard.clipsToBounds = true
        DispatchQueue.main.async {
                self.applyRandomCardUnselectedStyle()
        }
    }

    // Category Selection
    func handleSelection(of selectedCard: UIView) {

        isRandomCategorySelected = (selectedCard === randomCategoryCard)
        
        if selectedCard === countriesCard {
            selectedCategory = .countries
        } else if selectedCard === dailyObjectsCard {
            selectedCategory = .dailyObjects
        } else if selectedCard === gkCard {
            selectedCategory = .gk
        } else if selectedCard === foodCard {
            selectedCategory = .food
        } else if selectedCard === randomCategoryCard {
            selectedCategory = nil
        }

        let cards = [countriesCard, dailyObjectsCard, gkCard, foodCard, randomCategoryCard]

        for card in cards {
            guard let card else { continue }

            let isSelected = (card === selectedCard)

            UIView.animate(withDuration: 0.25) {
                card.backgroundColor = isSelected ? self.selectedBackground : .white
                card.layer.borderWidth = isSelected ? 2 : 0
                card.layer.borderColor = isSelected ? self.selectedBorderColor.cgColor : UIColor.clear.cgColor
            }

            if selectedCard === randomCategoryCard {
                applyRandomCardUnselectedStyle()
            } else {
                applyRandomCardUnselectedStyle()
            }

        }

        playButton.isEnabled = true
        playButton.alpha = 1.0
    }

    // Instructions Text
    private func setupInstructionsText() {
        let text = """
        1. Find and fill words in the crossword grid by identifying pictures.
        2. Tap letters to form words.
        3. Use Hint if needed.
        4. Enjoy solving the puzzle!
        """

        let paragraph = NSMutableParagraphStyle()
        paragraph.paragraphSpacing = 10

        instructionsLabel.attributedText = NSAttributedString(
            string: text,
            attributes: [.paragraphStyle: paragraph]
        )
    }

    // How To Play
    @IBAction func howToPlayTapped(_ sender: Any) {
        isHowToPlayOpen.toggle()

        let icon = isHowToPlayOpen ? "chevron.up" : "chevron.down"
        howToPlayChevronButton.setImage(UIImage(systemName: icon), for: .normal)

        UIView.animate(withDuration: 0.25) {
            self.instructionsCard.isHidden = !self.isHowToPlayOpen
            self.view.layoutIfNeeded()
        }
    }

    // Tap Gestures
    @IBAction func countriesTapped(_ sender: UITapGestureRecognizer) {
        handleSelection(of: countriesCard)
    }

    @IBAction func dailyObjectsTapped(_ sender: UITapGestureRecognizer) {
        handleSelection(of: dailyObjectsCard)
    }

    @IBAction func gkTapped(_ sender: UITapGestureRecognizer) {
        handleSelection(of: gkCard)
    }

    @IBAction func foodTapped(_ sender: UITapGestureRecognizer) {
        handleSelection(of: foodCard)
    }

    @IBAction func randomCategoryTapped(_ sender: UITapGestureRecognizer) {
        handleSelection(of: randomCategoryCard)
    }

    // Play Button
    @IBAction func playTapped(_ sender: UIButton) {
        let finalCategory: CrosswordCategory

        if isRandomCategorySelected {
            finalCategory = [.countries, .dailyObjects, .gk, .food].randomElement()!
            print("Randomly selected:", finalCategory.rawValue)
        } else {
            guard let category = selectedCategory else {
                print("No category selected")
                return
            }
            finalCategory = category
        }

        let storyboard = UIStoryboard(name: "GameScreens", bundle: nil)

        if let crosswordVC = storyboard.instantiateViewController(
            withIdentifier: "CrosswordViewController"
        ) as? CrosswordViewController {

            crosswordVC.selectedCategory = finalCategory
            navigationController?.pushViewController(crosswordVC, animated: true)
        }
    }
}
