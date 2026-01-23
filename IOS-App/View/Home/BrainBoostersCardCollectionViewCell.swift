//
//  BrainBoostersCardCollectionViewCell.swift
//  Home-Test
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class BrainBoostersCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var gameNameLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .white

        contentView.layer.cornerRadius = 34
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 6
        layer.masksToBounds = false

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: contentView.layer.cornerRadius
        ).cgPath
    }

    func configureBrainBoostersCell(brainBooster: BrainBoostersCardModel) {
        gameNameLabel.text = brainBooster.gameName
        imageView.image = UIImage(named: brainBooster.gameImage)
    }

}
