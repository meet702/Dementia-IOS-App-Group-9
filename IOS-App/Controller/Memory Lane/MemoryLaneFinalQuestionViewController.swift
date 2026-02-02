//import UIKit
//
//class MemoryLaneFinalQuestionViewController: UIViewController, UITextViewDelegate {
//
//    @IBOutlet weak var groupImage: UIImageView!
//    @IBOutlet weak var questionLabel: UILabel!
//    @IBOutlet weak var responseTextView: UITextView!
//    @IBOutlet weak var finishButton: UIButton!
//    @IBOutlet weak var backgroundView: UIView!
//    @IBOutlet weak var progressView: UIProgressView!
//    
//    var groupImageData: UIImage?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupPlaceholder()
//        enableKeyboardDismissOnTap()
//
//        progressView.progress = MemorySessionManager.shared.currentProgress()
//    }
//
//    private func setupUI() {
//
//        if let img = groupImageData {
//            groupImage.image = img
//        }
//
//        questionLabel.text =
//            "What comes to mind when you look at this picture?"
//        
//        backgroundView.layer.cornerRadius = 35
//        
//        responseTextView.delegate = self
//        responseTextView.layer.cornerRadius = 20
//        responseTextView.layer.borderWidth = 1.5
//        responseTextView.layer.borderColor =
//            UIColor(white: 0.85, alpha: 1).cgColor
//
//        responseTextView.textContainerInset =
//            UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
//
//        finishButton.backgroundColor =
//            UIColor(red: 1.0, green: 0.61, blue: 0.20, alpha: 1.0)
//    }
//
//    private func setupPlaceholder() {
//        responseTextView.text = "Add response"
//        responseTextView.textColor = .lightGray
//        responseTextView.resignFirstResponder()
//    }
//
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if textView.textColor == .lightGray {
//            textView.text = ""
//            textView.textColor = .black
//        }
//    }
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//            .isEmpty {
//            setupPlaceholder()
//        }
//    }
//
//    @IBAction func finishButtonTapped(_ sender: UIButton) {
//
//        let finalText =
//            (responseTextView.textColor == .lightGray)
//            ? ""
//            : (responseTextView.text ?? "")
//
//        MemorySessionManager.shared.finishImageSession(
//            overallReflection: finalText
//        )
//
//        progressView.setProgress(1.0, animated: false)
//
//        goToCompletionScreen()
//    }
//
//    private func goToCompletionScreen() {
//        let sb = UIStoryboard(name: "MemoryLane", bundle: nil)
//        let vc = sb.instantiateViewController(
//            withIdentifier: "ActivityOverviewVC"
//        )
//        navigationController?.pushViewController(vc, animated: false)
//    }
//}
