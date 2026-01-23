//
//  PersonImageViewController.swift
//  IOS-App
//
//  Created by SDC-USER on 20/01/26.
//

import UIKit
internal import CoreData

class PersonImageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photoEntities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonImageCell", for: indexPath)
        let imageViewTag = 1001
        let photo = photoEntities[indexPath.item]

        let imageView: UIImageView
        if let existing = cell.contentView.viewWithTag(imageViewTag) as? UIImageView {
            imageView = existing
        } else {
            imageView = UIImageView(frame: cell.contentView.bounds)
            imageView.tag = imageViewTag
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            cell.contentView.addSubview(imageView)
        }
        imageView.image = ImageStorageManager.shared.loadImage(from: photo.imagePath!)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        let photo = photoEntities[indexPath.item]

        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, actionProvider:  {_ in 
            
            let removeFromPerson = UIAction(
                title: "Remove from this person",
                image: UIImage(systemName: "person.fill.xmark")
            ) { _ in
                self.removePhotoFromPerson(photo)
            }
            
            let deleteEverywhere = UIAction(
                title: "Delete from all people",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self.deletePhotoEverywhere(photo)
            }
            
            return UIMenu(children: [removeFromPerson, deleteEverywhere])
        })
    }
    
    func removePhotoFromPerson(_ photo: PhotoEntity) {

        let context = PersistenceController.shared.context
        let person = context.object(with: personObjectID) as! PersonEntity

        let facesToRemove = (person.faces as? Set<FaceImageEntity>)?
            .filter { $0.photo == photo } ?? []

        for face in facesToRemove {
            context.delete(face)
        }

        try? context.save()
        loadPhotosForPerson()
    }

    func deletePhotoEverywhere(_ photo: PhotoEntity) {

        let context = PersistenceController.shared.context

        if let faces = photo.faces as? Set<FaceImageEntity> {
            for face in faces {
                context.delete(face)
            }
        }

        if let path = photo.imagePath {
            ImageStorageManager.shared.deleteImage(named: path)
        }

        context.delete(photo)

        try? context.save()
        loadPhotosForPerson()
    }

    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var personObjectID: NSManagedObjectID!

    private var photoEntities: [PhotoEntity] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
        imageCollectionView.collectionViewLayout = generateLayout()
        loadPhotosForPerson()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let context = PersistenceController.shared.context
        let person = context.object(with: personObjectID) as! PersonEntity
        title = person.name ?? "Person"
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in

            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0 / 3.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(125))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
            section.interGroupSpacing = 1

            return section
        }

        return layout
    }
    
    func loadPhotosForPerson() {

        let context = PersistenceController.shared.context
        let person = context.object(with: personObjectID) as! PersonEntity

        let faces = person.faces as? Set<FaceImageEntity> ?? []

        let uniquePhotos = Set(faces.compactMap { $0.photo })
        photoEntities = Array(uniquePhotos)

        imageCollectionView.reloadData()
    }

}
