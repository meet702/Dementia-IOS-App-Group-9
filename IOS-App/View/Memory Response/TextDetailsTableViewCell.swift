//
//  TextDetailsTableViewCell.swift
//  MemoryLaneResponseFeature
//
//  Created by SDC-USER on 16/12/25.
//

import UIKit

class TextDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var sfSymbolImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
        
    func configure(title: String, text: String, symbol: String) {
        titleLabel.text = title
        sfSymbolImage.image = UIImage(systemName: symbol)
        sfSymbolImage.tintColor = .orange
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 5
        paragraph.alignment = .left

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraph
        ]

        valueLabel.attributedText = NSAttributedString(
            string: text,
            attributes: attributes
        )
    }
}
