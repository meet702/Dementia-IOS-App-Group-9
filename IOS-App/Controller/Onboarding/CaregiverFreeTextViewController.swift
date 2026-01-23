//
//  CaregiverFreeTextViewController.swift
//  onboardingScreen
//
//  Created by SDC-USER on 16/12/25.
//

import UIKit

class CaregiverFreeTextViewController: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nextButton: UIButton!
    
    var startingStep = 6
    var totalSteps = 7
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableKeyboardDismissOnTap()
        setupUI()
        updateUI()
        setupTextViewPlaceholder()
        
    }
    
    
    private func setupUI() {
        nextButton.layer.cornerRadius = 27
        
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
    }
    
    private func updateUI() {
        progressView.progress = Float(startingStep) / Float(totalSteps)
        
    }
    
    private func setupTextViewPlaceholder() {
        textView.delegate = self
        textView.text = "Add response"
        textView.textColor = .darkGray
        textView.font = UIFont.systemFont(ofSize: 16)
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        
        let response = textView.text
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if response.isEmpty {
                showAlert("Please add a response.")
                return
            }

            performSegue(withIdentifier: "showCaregiverConnect", sender: nil)
        }
    }
    

    extension CaregiverFreeTextViewController: UITextViewDelegate {
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == .darkGray {
                textView.text = ""
                textView.textColor = .darkGray
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                textView.text = "Add response"
                textView.textColor = .darkGray
            }
        }
    }

