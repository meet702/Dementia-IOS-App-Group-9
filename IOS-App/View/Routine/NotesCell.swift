//
//  NotesCell.swift
//  TempApp
//
//  Created by SDC-USER on 05/12/25.
//

import UIKit

class NotesCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var notesTextView: UITextView!
    var onTextChanged: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        notesTextView.delegate = self
        notesTextView.textContainerInset = UIEdgeInsets(top: 10, left: 4, bottom: 10, right: 4)
    }
    
    func configure(text: String) {
        notesTextView.text = text
    }

    func textViewDidChange(_ textView: UITextView) {
        onTextChanged?(textView.text)
    }

}
