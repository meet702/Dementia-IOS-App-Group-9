//
//  AlbumCollectionViewCell.swift
//  IOS-App
//
//  Created by SDC-USER on 02/02/26.
//

import UIKit

class AlbumCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 3
        imageView.clipsToBounds = true
    }

    func configure(with image: WholeImage) {
        imageView.image = UIImage(contentsOfFile: image.imageURL.path)
    }

}
