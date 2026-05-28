import UIKit
import AVFoundation

class MemoryActionCell: UICollectionViewCell, AVAudioPlayerDelegate {

    @IBOutlet weak var shadowContainerView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var actionButton: UIButton!

    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!

    @IBOutlet weak var voiceContainerView: UIView!
    @IBOutlet weak var voiceDurationLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!

    private var audioPlayer: AVAudioPlayer?
    private var displayLink: CADisplayLink?
    private var isSeeking = false
    private var totalDuration: Double = 0
    private var currentContent: MemoryActionContent = .empty

    var onAddText: (() -> Void)?
    var onAddVoice: (() -> Void)?
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    var onDeleteVoice: (() -> Void)?

    var onContentDidChange: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupMenu()
        contentView.isUserInteractionEnabled = true
        cardView.isUserInteractionEnabled = true
        progressSlider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)

        for subview in cardView.subviews {
            if subview !== actionButton {
                subview.isUserInteractionEnabled = false
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        audioPlayer?.stop()
        audioPlayer = nil
        stopPlaybackTimer()
        progressSlider.value = 0
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)

        textLabel.text = nil
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {

        setNeedsLayout()
        layoutIfNeeded()

        let targetSize = CGSize(
            width: layoutAttributes.size.width,
            height: UIView.layoutFittingCompressedSize.height
        )

        let size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        var newFrame = layoutAttributes.frame
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }

    func configure(with content: MemoryActionContent) {
        currentContent = content

        actionButton.isHidden = true
        textContainerView.isHidden = true
        voiceContainerView.isHidden = true

        textLabel.text = nil

        switch content {

        case .empty:
            actionButton.isHidden = false
            moreButton.isHidden = true

        case .text(let text):
            textContainerView.isHidden = false
            moreButton.isHidden = false
            textLabel.text = text
            setupMoreMenu()

        case .voice(let url):
            voiceContainerView.isHidden = false
            voiceDurationLabel.text = getAudioDuration(from: url)
            progressSlider.value = 0
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }

        textLabel.invalidateIntrinsicContentSize()
        textContainerView.invalidateIntrinsicContentSize()
        contentView.invalidateIntrinsicContentSize()

        setNeedsLayout()
        layoutIfNeeded()

        DispatchQueue.main.async { [weak self] in
            self?.onContentDidChange?()
        }
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        layer.masksToBounds = false

        cardView.layer.cornerRadius = 31
        cardView.layer.masksToBounds = true

        textContainerView.layer.cornerRadius = 31
        textContainerView.layer.masksToBounds = true

        voiceContainerView.layer.cornerRadius = 31
        voiceContainerView.layer.masksToBounds = true

        shadowContainerView.layer.masksToBounds = false
        shadowContainerView.layer.shadowColor = UIColor.black.cgColor
        shadowContainerView.layer.shadowOpacity = 0.04
        shadowContainerView.layer.shadowRadius = 7
        shadowContainerView.layer.shadowOffset = CGSize(width: 0, height: 3)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shadowContainerView.layer.shadowPath = UIBezierPath(
            roundedRect: shadowContainerView.bounds,
            cornerRadius: 31
        ).cgPath
    }

    private func setupMenu() {
        let addText = UIAction(
            title: "Add text",
            image: UIImage(systemName: "text.bubble")
        ) { [weak self] _ in self?.onAddText?() }

        let addVoice = UIAction(
            title: "Add voice",
            image: UIImage(systemName: "mic")
        ) { [weak self] _ in self?.onAddVoice?() }

        actionButton.menu = UIMenu(children: [addText, addVoice])
        actionButton.showsMenuAsPrimaryAction = true
    }

    private func setupMoreMenu() {
        let edit = UIAction(
            title: "Edit",
            image: UIImage(systemName: "pencil")
        ) { [weak self] _ in self?.onEdit?() }

        let delete = UIAction(
            title: "Delete",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in self?.onDelete?() }

        moreButton.menu = UIMenu(children: [edit, delete])
        moreButton.showsMenuAsPrimaryAction = true
    }

    private func getAudioDuration(from url: URL) -> String {
        let asset = AVURLAsset(url: url)
        let duration = CMTimeGetSeconds(asset.duration)
        return formatTime(duration)
    }

    @IBAction func playTapped(_ sender: UIButton) {
        guard case let .voice(url) = currentContent else { return }

        if let player = audioPlayer, player.isPlaying {
            player.pause()
            stopPlaybackTimer()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            return
        }

        if let player = audioPlayer {
            player.play()
            startPlaybackTimer()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            totalDuration = audioPlayer?.duration ?? 0
            audioPlayer?.play()
            startPlaybackTimer()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } catch {
            print("Playback failed:", error)
        }
    }

    @IBAction func deleteVoiceTapped(_ sender: Any) {
        guard case let .voice(url) = currentContent else { return }
        try? FileManager.default.removeItem(at: url)
        audioPlayer?.stop()
        audioPlayer = nil
        stopPlaybackTimer()
        progressSlider.value = 0
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        onDeleteVoice?()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlaybackTimer()
        progressSlider.value = 0
        voiceDurationLabel.text = formatTime(totalDuration)
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        audioPlayer = nil
    }

    private func startPlaybackTimer() {
        stopPlaybackTimer()
        displayLink = CADisplayLink(target: self, selector: #selector(updateSlider))
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopPlaybackTimer() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updateSlider() {
        guard let player = audioPlayer, player.duration > 0, !isSeeking else { return }
        progressSlider.value = Float(player.currentTime / player.duration)
        voiceDurationLabel.text = formatTime(player.currentTime)
    }

    @IBAction func sliderTouchDown(_ sender: UISlider) { isSeeking = true }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        guard let player = audioPlayer else { return }
        player.currentTime = Double(sender.value) * player.duration
    }

    @IBAction func sliderTouchUp(_ sender: UISlider) { isSeeking = false }

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
