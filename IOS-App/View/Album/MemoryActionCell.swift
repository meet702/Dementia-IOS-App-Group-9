//
//  MemoryActionCell.swift
//  IOS-App
//
//  Created by SDC-USER on 04/02/26.
//

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
    private var playbackTimer: Timer?
    private var isSeeking = false
    
    private var displayLink: CADisplayLink?
    private var totalDuration: Double = 0

    private var currentContent: MemoryActionContent = .empty
    
    var onAddText: (() -> Void)?
    var onAddVoice: (() -> Void)?
    
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    
    var onDeleteVoice: (() -> Void)?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupMenu()
        audioPlayer?.volume = 1.0
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
    }


    
    override func preferredLayoutAttributesFitting(
            _ layoutAttributes: UICollectionViewLayoutAttributes
        ) -> UICollectionViewLayoutAttributes {

        setNeedsLayout()
        layoutIfNeeded()

        let size = contentView.systemLayoutSizeFitting(
            CGSize(width: layoutAttributes.size.width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        var newFrame = layoutAttributes.frame
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame

        return layoutAttributes
    }
    
    private func setupMoreMenu() {

        let edit = UIAction(
            title: "Edit",
            image: UIImage(systemName: "pencil")
        ) { [weak self] _ in
            self?.onEdit?()
        }

        let delete = UIAction(
            title: "Delete",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in
            self?.onDelete?()
        }

        moreButton.menu = UIMenu(children: [edit, delete])
        moreButton.showsMenuAsPrimaryAction = true
    }

    
    func configure(with content: MemoryActionContent) {
        currentContent = content 
        actionButton.isHidden = true
        textContainerView.isHidden = true
        voiceContainerView.isHidden = true

        switch content {

        case .empty:
            actionButton.isHidden = false
            textContainerView.isHidden = true
            moreButton.isHidden = true

        case .text(let text):
            actionButton.isHidden = true
            textContainerView.isHidden = false
            moreButton.isHidden = false
            textLabel.text = text
            setupMoreMenu()

        case .voice(let url):
            actionButton.isHidden = true
            textContainerView.isHidden = true

            voiceContainerView.isHidden = false

            let duration = getAudioDuration(from: url)
            voiceDurationLabel.text = duration
            progressSlider.value = 0
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            
        }
        
        setNeedsLayout()
        layoutIfNeeded()
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
        ) { [weak self] _ in
            self?.onAddText?()
        }

        let addVoice = UIAction(
            title: "Add voice",
            image: UIImage(systemName: "mic")
        ) { [weak self] _ in
            self?.onAddVoice?()
        }

        actionButton.menu = UIMenu(children: [addText, addVoice])
        actionButton.showsMenuAsPrimaryAction = true
    }
    
    private func getAudioDuration(from url: URL) -> String {
        let asset = AVURLAsset(url: url)
        let duration = CMTimeGetSeconds(asset.duration)

        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60

        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @IBAction func playTapped(_ sender: UIButton) {

        guard case let .voice(url) = currentContent else { return }

        // If already playing → pause
        if let player = audioPlayer, player.isPlaying {
            player.pause()
            stopPlaybackTimer()

            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            return
        }

        // If player exists but paused → resume
        if let player = audioPlayer {
            player.play()
            startPlaybackTimer()

            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            return
        }

        // First time play
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
            print("❌ Playback failed:", error)
        }
    }

    
    @IBAction func deleteVoiceTapped(_ sender: Any) {
        print("🗑 Delete voice tapped")

        guard case let .voice(url) = currentContent else { return }

        do {
            try FileManager.default.removeItem(at: url)
            print("✅ Audio file deleted")
        } catch {
            print("❌ Failed to delete audio:", error)
        }
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
        
        guard let player = audioPlayer,
              player.duration > 0,
              !isSeeking else { return }
        let currentTime = player.currentTime
        progressSlider.value = Float(player.currentTime / player.duration)
        voiceDurationLabel.text = formatTime(currentTime)

    }



    @IBAction func sliderTouchDown(_ sender: UISlider) {
        isSeeking = true
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        guard let player = audioPlayer else { return }

        let newTime = Double(sender.value) * player.duration
        player.currentTime = newTime
    }

    @IBAction func sliderTouchUp(_ sender: UISlider) {
        isSeeking = false
    }

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    
    

}
