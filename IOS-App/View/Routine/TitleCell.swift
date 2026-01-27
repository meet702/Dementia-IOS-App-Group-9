//
//  TitleCell.swift
//  TempApp
//
//  Created by SDC-USER on 05/12/25.
//

import UIKit

class TitleCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var titleTextView: UITextView!
    var onTextChanged: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleTextView.delegate = self
        titleTextView.textContainerInset = UIEdgeInsets(top: 10, left: 4, bottom: 10, right: 4)
    }
    
    func configure(text: String) {
        titleTextView.text = text
    }

    func textViewDidChange(_ textView: UITextView) {
        onTextChanged?(textView.text)
    }


}
