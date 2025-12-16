//
//  PeopleViewController.swift
//  Match the Pairs Test
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit
import Vision
import CoreData

class PeopleViewController: UIViewController,
                            UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate {

    @IBOutlet weak var PeoplecollectionView: UICollectionView!

    // MARK: - Data
    var people: [PeopleModel] = []
    private var selectedPerson: PeopleModel?   // ✅ ADDED

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell()
        PeoplecollectionView.dataSource = self
        PeoplecollectionView.delegate = self
        
        let layout = generateLayout()
        PeoplecollectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPeople()
    }

    // MARK: - Delete Person
    func deletePerson(_ person: PersonEntity) {

        let context = PersistenceController.shared.context

        if let imagePath = person.imagePath {
            ImageStorageManager.shared.deleteImage(named: imagePath)
        }

        context.delete(person)

        do {
            try context.save()
            print("🗑 Person deleted")
        } catch {
            print("❌ Failed to delete person:", error)
        }

        loadPeople()
    }

    // MARK: - Layout
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in

            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0 / 3.0),
                    heightDimension: .absolute(200)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(190)
                ),
                subitem: item,
                count: 3
            )

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 20, trailing: 20)
            section.interGroupSpacing = 8

            return section
        }

        return layout
    }

    // MARK: - Register Cell
    func registerCell() {
        PeoplecollectionView.register(
            UINib(nibName: "PeopleCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "peopleCollectionViewCell"
        )
    }

    // MARK: - Load People
    func loadPeople() {

        let context = PersistenceController.shared.context
        let request: NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()

        do {
            let results = try context.fetch(request)

            self.people = results.compactMap { entity in
                guard
                    let path = entity.imagePath,
                    let image = ImageStorageManager.shared.loadImage(from: path)
                else { return nil }

                return PeopleModel(
                    objectID: entity.objectID,
                    personName: entity.name ?? "Add Name",
                    personImage: image
                )
            }

            PeoplecollectionView.reloadData()

        } catch {
            print("❌ Failed to fetch people:", error)
        }
    }

    // MARK: - Save Person
    func savePerson(faceImage: UIImage) {

        let context = PersistenceController.shared.context

        guard let imagePath = ImageStorageManager.shared.saveImage(faceImage) else {
            return
        }

        let person = PersonEntity(context: context)
        person.id = UUID()
        person.name = "Add Name"
        person.imagePath = imagePath
        person.createdAt = Date()

        do {
            try context.save()
            print("✅ Person saved")
        } catch {
            print("❌ Failed to save person:", error)
        }
    }

    // MARK: - Add Photos Button
    @IBAction func addPhotosButton(_ sender: UIBarButtonItem) {

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        let alertController = UIAlertController(
            title: "Choose Image Source",
            message: nil,
            preferredStyle: .actionSheet
        )

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(
                UIAlertAction(title: "Camera", style: .default) { _ in
                    imagePicker.sourceType = .camera
                    self.present(imagePicker, animated: true)
                }
            )
        }

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alertController.addAction(
                UIAlertAction(title: "Photo Library", style: .default) { _ in
                    imagePicker.sourceType = .photoLibrary
                    self.present(imagePicker, animated: true)
                }
            )
        }

        alertController.popoverPresentationController?.barButtonItem = sender
        present(alertController, animated: true)
    }

    // MARK: - Image Picker Delegate
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        handleUploadedImage(image)
    }

    // MARK: - Face Segregation Logic
    private func handleUploadedImage(_ image: UIImage) {

        FaceDetectionManager.shared.detectFaces(in: image) { faceImages in
            for face in faceImages {
                self.savePerson(faceImage: face)
            }
            self.loadPeople()
        }
    }

    // MARK: - EDIT BUTTON ACTION (✅ ADDED)
    @objc private func editButtonTapped(_ sender: UIButton) {

        let index = sender.tag
        guard index >= 0, index < people.count else { return }

        selectedPerson = people[index]
        performSegue(withIdentifier: "showEditPerson", sender: selectedPerson)
    }

    // MARK: - PREPARE FOR SEGUE (✅ ADDED)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showEditPerson",
           let detailsVC = segue.destination as? DetailsTableViewController,
           let person = sender as? PeopleModel {

            detailsVC.person = person
        }
    }
}


// MARK: - UICollectionViewDataSource
extension PeopleViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "peopleCollectionViewCell",
            for: indexPath
        ) as! PeopleCollectionViewCell

        let person = people[indexPath.item]
        cell.configurePeopleCell(person: person)

        // 🔹 Existing edit button logic (unchanged)
        cell.editButton.tag = indexPath.item
        cell.editButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.editButton.addTarget(
            self,
            action: #selector(editButtonTapped(_:)),
            for: .touchUpInside
        )

        cell.onNameUpdated = { newName in
            let model = self.people[indexPath.item]
            let context = PersistenceController.shared.context
            let personEntity = context.object(with: model.objectID) as! PersonEntity

            personEntity.name = newName
            try? context.save()

            self.loadPeople()
        }


        return cell
    }

    
}

// MARK: - UICollectionViewDelegate
extension PeopleViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {

        let model = people[indexPath.item]

        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { _ in

            let delete = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                let context = PersistenceController.shared.context
                let person = context.object(with: model.objectID) as! PersonEntity
                self.deletePerson(person)
            }

            return UIMenu(title: "", children: [delete])
        }
    }
}
