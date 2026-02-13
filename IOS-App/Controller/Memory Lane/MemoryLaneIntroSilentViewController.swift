import UIKit

final class MemoryLaneIntroSilentViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var hintLabel: UILabel!
    @IBOutlet weak var innerShadowView: UIView!
    @IBOutlet weak var bottomBlurView: UIVisualEffectView!
    @IBOutlet weak var topBlurView: UIVisualEffectView!
    
    // MARK: - Dependencies (Injected)

    var wholeImage: WholeImage!
    var faces: [Face] = []
    var people: [Person] = []
    var questionsByPerson: [UUID: [Question]] = [:]
    var portraitImage: UIImage!
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔍 SilentVC viewDidLoad:")
//        print("   WholeImage ID: \(wholeImage.wid)")
        print("   Faces: \(faces.count)")
        print("   People: \(people.count)")
        
        configureUI()
        loadImage()
        configureEdgeBlur()
        setupTapGesture()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateHint()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addInnerShadow()
        applyFadeMask(to: topBlurView, isTop: true)
        applyFadeMask(to: bottomBlurView, isTop: false)
    }

    // MARK: - UI Setup

    private func configureUI() {
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false

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
    
    private func configureEdgeBlur() {
        topBlurView.alpha = 0.9
        bottomBlurView.alpha = 0.9

        topBlurView.isUserInteractionEnabled = false
        bottomBlurView.isUserInteractionEnabled = false
    }

    private func loadImage() {
        // For testing: use hardcoded portrait
        imageView.image = portraitImage
        
        // TODO: When ready for real images:
        // guard let image = UIImage(contentsOfFile: wholeImage.imageURL.path) else { return }
        // imageView.image = image
    }

    // MARK: - Tap Handling

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

    // MARK: - Hint Animation

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
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAudioIntro",
           let audioVC = segue.destination as? MemoryLaneIntroAudioVC {

            audioVC.wholeImage = wholeImage
            audioVC.faces = faces
            audioVC.people = people
            audioVC.questionsByPerson = questionsByPerson
            audioVC.portraitImage = portraitImage   
        }
    }

}
