import UIKit

class HeaderView: UICollectionReusableView {

    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    private var tapGesture: UITapGestureRecognizer?
    private var onTapAction: (() -> Void)?
    func configureHeaderCell(text: String, showChevron: Bool, isTappable: Bool, onTap: (() -> Void)? = nil) {
        titleLabel.text = text
        chevronImageView.isHidden = !showChevron
        self.onTapAction = onTap

        if isTappable {
            if tapGesture == nil {
                let g = UITapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
                addGestureRecognizer(g)
                tapGesture = g
            }
            tapGesture?.isEnabled = true
            self.isUserInteractionEnabled = true
        } else {
            tapGesture?.isEnabled = false
            self.isUserInteractionEnabled = false
        }
    }

    @objc private func headerTapped(_ sender: UITapGestureRecognizer) {
        onTapAction?()
    }

}
