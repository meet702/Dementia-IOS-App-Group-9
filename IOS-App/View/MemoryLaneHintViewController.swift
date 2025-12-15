import UIKit

class MemoryLaneHintViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!

    private var initialY: CGFloat = 0
    var hintText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // start with transparent background
        view.backgroundColor = UIColor.black.withAlphaComponent(0.0)

        // popup style
        containerView.layer.cornerRadius = 24
        containerView.layer.masksToBounds = true
        
        // shadow for good UX
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowRadius = 12
        containerView.layer.shadowOffset = CGSize(width: 0, height: 3)

        // populate hint text
        messageLabel.text = hintText

        // start position (hidden)
        containerView.transform = CGAffineTransform(translationX: 0, y: 600)

        // enable drag down
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        containerView.addGestureRecognizer(panGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }

    private func animateIn() {
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.7,
            options: .curveEaseOut,
            animations: {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
                self.containerView.transform = .identity
            },
            completion: nil
        )
    }

    private func animateOut(completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                self.containerView.transform = CGAffineTransform(translationX: 0, y: 600)
            },
            completion: { _ in completion?() }
        )
    }

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        animateOut { self.dismiss(animated: false) }
    }

    // MARK: - Tap outside to close
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self.view)

        // if tap outside popup
        if !containerView.frame.contains(location) {
            animateOut { self.dismiss(animated: false) }
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        switch gesture.state {
        case .began:
            initialY = containerView.frame.origin.y

        case .changed:
            if translation.y > 0 { // drag only down
                containerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }

        case .ended, .cancelled:
            let velocity = gesture.velocity(in: view).y

            // if dragged enough or fast → close
            if translation.y > 120 || velocity > 600 {
                animateOut { self.dismiss(animated: false) }
            } else {
                // reset position
                UIView.animate(withDuration: 0.25) {
                    self.containerView.transform = .identity
                }
            }

        default:
            break
        }
    }
}

