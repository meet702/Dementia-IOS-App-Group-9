import UIKit
import AVFoundation

class VoiceRecorderViewController: UIViewController {

    @IBOutlet weak var recordButton: UIButton!

    @IBOutlet weak var timerLabel: UILabel!
    var onRecordingFinished: ((URL) -> Void)?

    private var audioRecorder: AVAudioRecorder?
    private var isRecording = false

    private var timer: Timer?
    private var recordingStartDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        requestPermission()
    }

    private func requestPermission() {

        if #available(iOS 17.0, *) {

            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                    } else {
                    }
                }
            }

        } else {

            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                    } else {
                    }
                }
            }

        }
    }

    @IBAction func recordTapped(_ sender: UIButton) {

        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {

        recordingStartDate = Date()
        startTimer()

        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            let url = getRecordingURL()

            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()

            isRecording = true

            recordButton.tintColor = .systemGray

        } catch {
            print("Failed to start recording:", error)
        }
    }

    private func stopRecording() {

        stopTimer()

        guard let recorder = audioRecorder else {
            dismiss(animated: true)
            return
        }

        recorder.stop()
        isRecording = false

        let recordedURL = recorder.url

        audioRecorder = nil

        onRecordingFinished?(recordedURL)
        try? AVAudioSession.sharedInstance().setActive(false)

        dismiss(animated: true)
    }

    private func getRecordingURL() -> URL {

        let fileName = UUID().uuidString + ".m4a"

        return FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
    }

    @objc private func updateTimer() {
        guard let start = recordingStartDate else { return }

        let elapsed = Int(Date().timeIntervalSince(start))
        let minutes = elapsed / 60
        let seconds = elapsed % 60

        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

}
