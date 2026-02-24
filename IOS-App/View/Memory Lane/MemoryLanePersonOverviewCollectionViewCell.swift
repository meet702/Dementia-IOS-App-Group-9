////
////  MemoryLanePersonOverviewCollectionViewCell.swift
////  MemoryLane
////
////  Created by SDC-User on 11/12/25.
////
//
//import UIKit
//
//class MemoryLanePersonOverviewCollectionViewCell: UICollectionViewCell {
//
//    @IBOutlet weak var containerView: UIView!
//    
//    @IBOutlet weak var personImage: UIImageView!
//    
//    @IBOutlet weak var nameLabel: UILabel!
//    
//    @IBOutlet weak var summaryLabel: UILabel!
//    
//    func beautify() {
//        containerView.layer.cornerRadius = 34
//        containerView.clipsToBounds = true
//        
//        personImage.layer.cornerRadius = 31
//        personImage.clipsToBounds = true
//        
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOpacity = 0.05
//        layer.shadowOffset = CGSize(width: 0, height: 4)
//        layer.shadowRadius = 8
//        layer.masksToBounds = false
//    }
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//        beautify()
//    }
//
//    func configurePersonOverview(person: PersonData) {
//        personImage.image = UIImage(named: person.personImage)
//        nameLabel.text = person.name
//        summaryLabel.text = person.summary
//    }
//}
