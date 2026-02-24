//
//  EmptyStateCollectionViewCell.swift
//  IOS-App
//
//  Created by SDC-USER on 28/01/26.
//

import UIKit

class EmptyStateCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.font = .preferredFont(forTextStyle: .callout)
        //titleLabel.textColor = .systemGray
        subtitleLabel.textColor = .systemGray
        containerView.layer.cornerRadius = 34
        containerView.layer.masksToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.masksToBounds = false
    }
    
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

}
