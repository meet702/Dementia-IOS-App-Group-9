//
//  CrosswordInstructionsViewController.swift
//  IOS-App
//
//  Created by SDC-USER on 17/12/25.
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
    
    var isHowToPlayOpen = false
    private var selectedCard: UIView?

    private let selectedBackground = UIColor(
           red: 1.0,
           green: 0.75,
           blue: 0.46,
           alpha: 0.25
       )
       private let unselectedBackground = UIColor.white

       private let selectedBorderColor = UIColor(
           red: 1.0,
           green: 0.6,
           blue: 0.2,
           alpha: 1.0
       )
       private let unselectedBorderColor = UIColor.clear

       private var allCards: [UIView] {
           return [countriesCard, dailyObjectsCard, gkCard, foodCard, randomCategoryCard, instructionsCard, howToPlayView]
       }
    
    override func viewDidLoad() {
           super.viewDidLoad()

           instructionsCard.isHidden = true
           howToPlayChevronButton.isUserInteractionEnabled = false

           for card in allCards {
               card.layer.cornerRadius = 20
               card.backgroundColor = unselectedBackground
               card.layer.borderWidth = 0
               card.layer.borderColor = unselectedBorderColor.cgColor
               card.clipsToBounds = true
           }
       }

    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
        applyRandomCardUnselectedStyle()
        }

    func animateCardTransition(card: UIView,
                               toColor: UIColor,
                               borderColor: UIColor?) {
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


    func handleSelection(of selectedCard: UIView) {
        let allCards = [countriesCard, dailyObjectsCard, gkCard, foodCard, randomCategoryCard]

        let selectedBG = UIColor(red: 1.0, green: 0.75, blue: 0.46, alpha: 0.25)
        let selectedBorderColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)

        for cardOpt in allCards {
            guard let card = cardOpt else { continue }

            let isSelected = (card === selectedCard)

            if isSelected {
                animateCardTransition(card: card,
                                      toColor: selectedBG,
                                      borderColor: selectedBorderColor)

                if card === randomCategoryCard {
                    applyRandomCardSelectedStyle()
                }
            } else {
                animateCardTransition(card: card,
                                      toColor: .white,
                                      borderColor: nil)

                if card === randomCategoryCard {
                    applyRandomCardUnselectedStyle()
                }
            }

            if card !== randomCategoryCard {
                card.layer.cornerRadius = 20
            }
        }
    }

       private func addDashedBorderToRandomCard() {
           randomCategoryCard.layer.sublayers?
               .filter { $0.name == "dashedBorder" }
               .forEach { $0.removeFromSuperlayer() }

           let shapeLayer = CAShapeLayer()
           shapeLayer.name = "dashedBorder"
           shapeLayer.path = UIBezierPath(
               roundedRect: randomCategoryCard.bounds,
               cornerRadius: 20
           ).cgPath
           shapeLayer.strokeColor = selectedBorderColor.withAlphaComponent(0.6).cgColor
           shapeLayer.fillColor = UIColor.clear.cgColor
           shapeLayer.lineWidth = 2
           shapeLayer.lineDashPattern = [6, 4]

           randomCategoryCard.layer.addSublayer(shapeLayer)
       }
    
    func applyRandomCardSelectedStyle() {
        guard let card = randomCategoryCard else { return }

        card.layer.sublayers?.removeAll(where: { $0.name == "RandomDashedBorder" })

        let selectedBorderColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)

        card.layer.borderWidth = 2
        card.layer.borderColor = selectedBorderColor.cgColor
        card.layer.cornerRadius = 25
        card.layer.masksToBounds = true
    }

    func applyRandomCardUnselectedStyle() {
        guard let card = randomCategoryCard else { return }

        card.layer.sublayers?.removeAll(where: { $0.name == "RandomDashedBorder" })

        card.layer.borderWidth = 0
        card.layer.cornerRadius = 25
        card.layer.masksToBounds = true

        let dashed = CAShapeLayer()
        dashed.name = "RandomDashedBorder"
        dashed.strokeColor = UIColor.orange.cgColor
        dashed.lineDashPattern = [6, 4]
        dashed.fillColor = UIColor.clear.cgColor
        dashed.lineWidth = 2

        dashed.path = UIBezierPath(roundedRect: card.bounds,
                                   cornerRadius: 25).cgPath
        dashed.frame = card.bounds

        card.layer.addSublayer(dashed)
    }

   

    @IBAction func howToPlayTapped(_ sender: Any) {
        isHowToPlayOpen.toggle()

                let imageName = isHowToPlayOpen ? "chevron.up" : "chevron.down"
                howToPlayChevronButton.setImage(UIImage(systemName: imageName), for: .normal)

                UIView.animate(withDuration: 0.25) {
                    self.instructionsCard.isHidden = !self.isHowToPlayOpen
                    self.view.layoutIfNeeded()   // stack view smoothly moves everything
                }
    }
    
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
    

    @IBAction func playTapped(_ sender: UIButton) {
    }
    
}
