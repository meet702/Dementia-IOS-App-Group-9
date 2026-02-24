//
//  RoleCardCollectionViewCell.swift
//  onboardingScreen
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class RoleCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 34
        containerView.clipsToBounds = true
        containerView.backgroundColor = .white
        layer.shadowColor = UIColor.systemOrange.cgColor
        layer.shadowOpacity = 0.20
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.masksToBounds = false
    }

    func configure(with model: RoleModel) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
    }
}
