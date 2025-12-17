//
//  PersonTableViewCell.swift
//  MemoryLaneResponseFeature
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class PersonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var personImageView: UIImageView!
    
    @IBOutlet weak var personNameLabel: UILabel!
    
    var onChevronTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(person: PersonSession) {
        personImageView.image = UIImage(named: person.image)
        personImageView.layer.cornerRadius = 26
        personNameLabel.text = person.personName
    }
    

    @IBAction func chevronTapped(_ sender: UIButton) {
        //print("chevron tapped")
        onChevronTapped?()
    }
    

}
