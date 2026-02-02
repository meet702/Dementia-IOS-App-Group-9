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
//        titleLabel.textColor = .systemGray
        subtitleLabel.textColor = .systemGray
//        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
    }
    
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

}
