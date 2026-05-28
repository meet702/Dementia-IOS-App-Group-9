import UIKit

final class MemoryLaneIntroSilentViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var hintLabel: UILabel!
    @IBOutlet weak var innerShadowView: UIView!

    @IBOutlet weak var backgroundImageView: UIImageView!

    var wholeImage: WholeImage!
    var faces: [Face] = []
    var questionsByPerson: [String: [Question]] = [:]
    var portraitImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        loadImage()
        setupTapGesture()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateHint()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addInnerShadow()
    }

    private func configureUI() {
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false

        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true

        hintLabel.text = "Tap to zoom into the moment"
        hintLabel.textAlignment = .center
        hintLabel.textColor = UIColor.systemGray3

        innerShadowView.backgroundColor = .clear
        innerShadowView.isUserInteractionEnabled = false
    }

    private func applyFadeMask(to blurView: UIVisualEffectView, isTop: Bool) {
        let maskLayer = CAGradientLayer()
        maskLayer.frame = blurView.bounds

        if isTop {
            maskLayer.colors = [
                UIColor.black.cgColor,
                UIColor.black.withAlphaComponent(0).cgColor
            ]
            maskLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            maskLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)
        } else {
            maskLayer.colors = [
                UIColor.black.withAlphaComponent(0).cgColor,
                UIColor.black.cgColor
            ]
            maskLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            maskLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)
        }

        blurView.layer.mask = maskLayer
    }

    private func makeLowResolutionImage(from image: UIImage) -> UIImage {

        let scale: CGFloat = 0.08

        let targetSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )

        UIGraphicsBeginImageContextWithOptions(targetSize, true, 1)

        image.draw(in: CGRect(origin: .zero, size: targetSize))

        let lowResImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return lowResImage ?? image
    }

    private func loadImage() {

        imageView.image = portraitImage

        backgroundImageView.image = makeLowResolutionImage(from: portraitImage)
    }

    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleScreenTap)
        )
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
    }

    @objc private func handleScreenTap() {
        performSegue(withIdentifier: "showAudioIntro", sender: nil)
    }

    private func animateHint() {
        UIView.animate(
            withDuration: 0,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                self.hintLabel.alpha = 1
            }
        )
    }

    private func addInnerShadow() {
        innerShadowView.layer.sublayers?
            .removeAll(where: { $0.name == "InnerShadow" })

        let shadowLayer = CAShapeLayer()
        shadowLayer.name = "InnerShadow"
        shadowLayer.frame = innerShadowView.bounds

        let cornerRadius: CGFloat = 0

        let innerPath = UIBezierPath(
            roundedRect: innerShadowView.bounds,
            cornerRadius: cornerRadius
        )

        let outerPath = UIBezierPath(
            rect: innerShadowView.bounds
        )

        outerPath.append(innerPath)
        outerPath.usesEvenOddFillRule = true

        shadowLayer.path = outerPath.cgPath
        shadowLayer.fillRule = .evenOdd
        shadowLayer.fillColor = UIColor.black.cgColor
        shadowLayer.opacity = 0.28
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = .zero
        shadowLayer.shadowRadius = 0

        shadowLayer.mask = {
            let mask = CAShapeLayer()
            mask.path = innerPath.cgPath
            return mask
        }()

        innerShadowView.layer.addSublayer(shadowLayer)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAudioIntro",
           let audioVC = segue.destination as? MemoryLaneIntroAudioVC {

            audioVC.wholeImage = wholeImage
            audioVC.faces = faces
            audioVC.questionsByPerson = questionsByPerson
            audioVC.portraitImage = portraitImage
        }
    }

}
