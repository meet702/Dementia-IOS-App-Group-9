//
//  AddTextViewController.swift
//  IOS-App
//
//  Created by SDC-USER on 10/02/26.
//

import UIKit

class AddTextViewController: UIViewController, UITextViewDelegate {

       @IBOutlet weak var titleLabel: UILabel!
       @IBOutlet weak var textView: UITextView!
       @IBOutlet weak var saveButton: UIButton!

       var prefilledText: String?

       var onSave: ((String) -> Void)?

       override func viewDidLoad() {
           super.viewDidLoad()
           setupUI()
       }

       private func setupUI() {
           titleLabel.text = "Add Text"

           textView.font = .preferredFont(forTextStyle: .body)
           textView.layer.cornerRadius = 16
           textView.layer.masksToBounds = true
           textView.delegate = self

           if let prefilledText, !prefilledText.isEmpty {
               textView.text = prefilledText
               textView.textColor = .label
           } else {
               textView.text = "Write about this memory"
               textView.textColor = .secondaryLabel
           }

           textView.becomeFirstResponder()
       }

       @IBAction func saveTapped(_ sender: UIButton) {
           let text = textView.textColor == .secondaryLabel ? "" : textView.text
           onSave?(text ?? "")
           dismiss(animated: true)
       }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .secondaryLabel {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "Write about this memory"
            textView.textColor = .secondaryLabel
        }
    }


}
