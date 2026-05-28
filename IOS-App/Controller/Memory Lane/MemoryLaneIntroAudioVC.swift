import UIKit
import AVFoundation

final class MemoryLaneIntroAudioVC: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var progressSlider: UISlider!
    @IBOutlet private weak var continueLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var innerShadowView: UIView!
    @IBOutlet weak var caregiverTextLabel: UILabel!

    @IBOutlet weak var backgroundImageView: UIImageView!

    private var delayedPlaybackWorkItem: DispatchWorkItem?

    var portraitImage: UIImage!
    var wholeImage: WholeImage!
    var faces: [Face] = []
    var questionsByPerson: [String: [Question]] = [:]

    private var isPlaying = false

    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        styleSlider()
        loadImage()
        prepareForFadeIn()
        configureMemoryAction()
        setupTapGesture()
    }

    private func animateControlsIn() {
        UIView.animate(
            withDuration: 0.6,
            delay: 0.4,
            options: [.curveEaseOut],
            animations: {
                self.continueLabel.alpha = 1
                self.commentLabel.alpha = 1
                self.playPauseButton.transform = .identity
            }
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let container = imageView.superview else { return }

        container.bringSubviewToFront(innerShadowView)
        container.bringSubviewToFront(playPauseButton)
        container.bringSubviewToFront(progressSlider)
        container.bringSubviewToFront(continueLabel)

        animateControlsIn()

        commentLabel.alpha = 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.replaceCommentWithCaregiverContent()
        }

        animateContinueHint()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        delayedPlaybackWorkItem?.cancel()
        stopAudio()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addInnerShadow()
    }

    private func applyFadeMask(to blurView: UIVisualEffectView, isTop: Bool) {
        let maskLayer = CAGradientLayer()
        maskLayer.frame = blurView.bounds

        if isTop {
            maskLayer.colors = [
                UIColor.black.cgColor,
                UIColor.black.withAlphaComponent(0).cgColor
            ]
        } else {
            maskLayer.colors = [
                UIColor.black.withAlphaComponent(0).cgColor,
                UIColor.black.cgColor
            ]
        }

        maskLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        maskLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)

        blurView.layer.mask = maskLayer
    }

    private func replaceCommentWithCaregiverContent() {

        UIView.animate(withDuration: 0.4, animations: {
            self.commentLabel.alpha = 0
        }) { _ in

            guard let action = self.wholeImage.action else {
                self.goToNextScreen()
                return
            }

            switch action {

            case .text(let text):
                self.showText(text)

                UIView.animate(withDuration: 0.4) {
                    self.caregiverTextLabel.alpha = 1
                }

            case .voice(let url):

                self.showAudio(from: url)

                UIView.animate(withDuration: 0.4) {
                    self.playPauseButton.alpha = 1
                    self.progressSlider.alpha = 1
                }

                self.playAudio()

            case .empty:
                self.goToNextScreen()
            }
        }
    }

    private func showAudio(from url: URL) {

        caregiverTextLabel.isHidden = true

        playPauseButton.isHidden = false
        progressSlider.isHidden = false

        setupAudio(from: url)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.playAudio()
        }
    }

    private var pendingAction: MemoryActionContent?

    private func configureMemoryAction() {
        pendingAction = wholeImage.action
    }

    private func hideAllActionViews() {
        playPauseButton.isHidden = true
        progressSlider.isHidden = true
        caregiverTextLabel.isHidden = true
    }

    private func showText(_ text: String) {
        caregiverTextLabel.text = text
        caregiverTextLabel.numberOfLines = 0
        caregiverTextLabel.textAlignment = .center

        caregiverTextLabel.isHidden = false

        playPauseButton.isHidden = true
        progressSlider.isHidden = true
    }

    private func showEmpty(_ text: String) {
        caregiverTextLabel.text = text
        caregiverTextLabel.numberOfLines = 0
        caregiverTextLabel.textAlignment = .center

        caregiverTextLabel.isHidden = false

        playPauseButton.isHidden = true
        progressSlider.isHidden = true
    }

    private func showAudio(_ url: URL) {
        caregiverTextLabel.isHidden = true

        playPauseButton.isHidden = false
        progressSlider.isHidden = false

        setupAudio(from: url)
    }

    private func setupAudio(from url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.delegate = self

            progressSlider.minimumValue = 0
            progressSlider.maximumValue = Float(audioPlayer?.duration ?? 0)
        } catch {
            print("Audio setup failed:", error)
        }
    }

    private func prepareForFadeIn() {
        playPauseButton.alpha = 0
        progressSlider.alpha = 0
        caregiverTextLabel.alpha = 0

        commentLabel.alpha = 0
        continueLabel.alpha = 0

        playPauseButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        playPauseButton.isHidden = true
        progressSlider.isHidden = true
        caregiverTextLabel.isHidden = true
    }

    private func configureUI() {
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false

        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true

        progressSlider.minimumValue = 0
        progressSlider.value = 0

        commentLabel.text = "Here's what was said about this memory"

        continueLabel.text = "Tap to continue"
        continueLabel.alpha = 0
        continueLabel.textColor = .systemGray3

        playPauseButton.setImage(
            UIImage(systemName: "play.fill"),
            for: .normal
        )
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
        guard let image = LocalImageStore.shared.fetchImage(by: wholeImage.wid) else {
            print("Failed to load image from LocalImageStore")
            return
        }
        imageView.image = image
        backgroundImageView.image = makeLowResolutionImage(from: image)
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        stopProgressTimer()
        progressSlider.value = progressSlider.minimumValue
        updatePlayPauseIcon()
    }

    private func playAudio() {
        audioPlayer?.play()
        isPlaying = true
        updatePlayPauseIcon()
        startProgressTimer()
    }

    private func pauseAudio() {
        audioPlayer?.pause()
        isPlaying = false
        updatePlayPauseIcon()
        stopProgressTimer()
    }

    private func updatePlayPauseIcon() {
        let iconName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: iconName), for: .normal)
    }

    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        audioPlayer?.delegate = nil
        audioPlayer = nil

        stopProgressTimer()

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func startProgressTimer() {
        stopProgressTimer()

        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self,
                  let player = self.audioPlayer else { return }
            self.progressSlider.value = Float(player.currentTime)
        }
    }

    private func styleSlider() {
        progressSlider.minimumTrackTintColor = UIColor.white.withAlphaComponent(0.6)
        progressSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.25)
        progressSlider.backgroundColor = .clear

        let thumb = makeCircleThumb(diameter: 18, color: .white)
        progressSlider.setThumbImage(thumb, for: .normal)
        progressSlider.setThumbImage(thumb, for: .highlighted)
    }

    private func makeCircleThumb(diameter: CGFloat, color: UIColor) -> UIImage {
        let size = CGSize(width: diameter, height: diameter)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return UIImage() }
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: CGRect(origin: .zero, size: size))
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        return image
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    @IBAction private func playPauseTapped(_ sender: UIButton) {
        isPlaying ? pauseAudio() : playAudio()
    }

    @IBAction private func sliderChanged(_ sender: UISlider) {
        audioPlayer?.currentTime = TimeInterval(sender.value)
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

    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleScreenTap)
        )
        view.addGestureRecognizer(tap)
    }

    @objc private func handleScreenTap() {
        stopAudio()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.performSegue(withIdentifier: "showFirstFace", sender: nil)
        }
    }

    private func animateContinueHint() {
        UIView.animate(
            withDuration: 0,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                self.continueLabel.alpha = 1
            }
        )
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFirstFace",
           let faceVC = segue.destination as? FaceViewController {

            faceVC.wholeImage = wholeImage
            faceVC.faces = faces
            faceVC.questionsByPerson = questionsByPerson
            faceVC.portraitImage = portraitImage
        }
    }

    private func goToNextScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.performSegue(withIdentifier: "showFirstFace", sender: nil)
        }
    }
}
