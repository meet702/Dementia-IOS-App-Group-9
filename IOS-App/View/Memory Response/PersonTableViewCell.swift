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
    
    func configure(
        personSession: PersonSession,
        imageID: UUID
    ) {

        // Load face image (image-scoped) using personName
        let faces = FaceStore.shared.loadFaces(for: imageID)

        let face = faces.first(where: { $0.fid == personSession.fid })

        if let face = face {
            let url = FaceStore.shared.faceImageURL(for: face.fileName)

            if FileManager.default.fileExists(atPath: url.path) {
                personImageView.image = UIImage(contentsOfFile: url.path)
            } else {
                personImageView.image = UIImage(systemName: "person.crop.circle.fill")
            }
        } else {
            personImageView.image = UIImage(systemName: "person.crop.circle.fill")
        }

        // Load person name from the matched face
        let name = face?.personName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if !name.isEmpty {
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
