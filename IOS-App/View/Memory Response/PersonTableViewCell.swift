//
//  PersonTableViewCell.swift
//  MemoryLaneResponseFeature
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

final class PersonTableViewCell: UITableViewCell {

    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var personNameLabel: UILabel!

    var onChevronTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        personImageView.layer.cornerRadius = 26
        personImageView.clipsToBounds = true
    }

    // MARK: - Configure (NEW MODEL)

//    func configure(personSession: PersonSession) {
//
//        // Load face image if available
//        if let faceImage = FaceStore.shared.faceImage(for: personSession.personID) {
//            personImageView.image = faceImage
//        } else {
//            personImageView.image = UIImage(systemName: "person.crop.circle")
//        }
//
//        // Load person name if available
//        if let person = PersonStore.shared.person(by: personSession.personID),
//           let name = person.name,
//           !name.isEmpty {
//
//            personNameLabel.text = name
//        } else {
//            personNameLabel.text = "Someone in this memory"
//        }
//    }
    
    func configure(
        personSession: PersonSession,
        imageID: UUID
    ) {

        // Load face image (image-scoped)
        if let face = FaceStore.shared.face(
            for: personSession.personID,
            in: imageID
        ) {

            let url = FaceStore.shared.faceImageURL(for: face.fileName)

            if FileManager.default.fileExists(atPath: url.path) {
                personImageView.image = UIImage(contentsOfFile: url.path)
            } else {
                personImageView.image = UIImage(systemName: "person.crop.circle.fill")
            }

        } else {
            personImageView.image = UIImage(systemName: "person.crop.circle.fill")
        }

        // Load person name
        if let person = PersonStore.shared.person(by: personSession.personID),
           let name = person.name,
           !name.isEmpty {

            personNameLabel.text = name
        } else {
            personNameLabel.text = "Someone in this memory"
        }
    }


    // MARK: - Actions

    @IBAction func chevronTapped(_ sender: UIButton) {
        onChevronTapped?()
    }
}
