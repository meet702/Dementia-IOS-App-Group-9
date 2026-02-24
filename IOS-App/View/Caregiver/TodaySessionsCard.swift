//
//  TodaySessionsCard.swift
//  Match the Pairs Test
//
//  Created by SDC-USER on 05/12/25.
//

import UIKit

class TodaySessionsCard: UICollectionViewCell {

    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        cardView.layer.cornerRadius = 18
        cardView.clipsToBounds = true
        cardView.backgroundColor = .white

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.masksToBounds = false
    }
    
    func configure(imageSession: ImageSession) {

            // Date & time
            dateLabel.text = imageSession.startedAt.formattedDate()
            timeLabel.text = imageSession.startedAt.formattedTime()

            // Fetch image using imageID
            if let image = LocalImageStore.shared.fetchImage(by: imageSession.imageID) {
                imageView.image = image
            } else {
                imageView.image = UIImage(systemName: "photo")
            }
        }
    
    
}
