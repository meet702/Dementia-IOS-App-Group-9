//
//  HintCell.swift
//  IOS-App
//
//  Created by SDC-USER on 09/01/26.
//

import UIKit

class HintCell: UICollectionViewCell {
    
    @IBOutlet weak var hintLabel: UILabel!
    
    func configure(with hint: CrosswordWord) {
        hintLabel.text = hint.answer
    }
}
