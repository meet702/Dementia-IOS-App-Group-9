import UIKit

class AlbumCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 3
        imageView.clipsToBounds = true
    }

    func configure(with image: WholeImage) {
        imageView.image = LocalImageStore.shared.fetchImage(by: image.wid)
    }

}
