//
//  ImageDetailsViewController.swift
//  IOS-App
//
//  Created by SDC-USER on 03/02/26.
//

import UIKit


class ImageDetailsViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    enum MemorySection: Int, CaseIterable {
        case hero = 0
        case actions = 1
        case people = 2
    }

    
    var wholeImage: WholeImage?
    private var heroUIImage: UIImage?
    private var faces: [Face] = []
    private var heroAspectRatio: CGFloat = 1.0
    private var activeFaceIndexPath: IndexPath?
    private var memoryActionContent: MemoryActionContent = .empty


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = createLayout()
        registerCells()
        loadHeroImageAndDetectFaces()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func loadHeroImageAndDetectFaces() {
        
        print("Loaded action:", memoryActionContent)
        
        if let id = wholeImage?.wid,
           let stored = LocalImageStore.shared.fetchImageModel(by: id) {

            self.wholeImage = stored
            self.memoryActionContent = stored.action!

            print("📦 Loaded persisted action:", stored.action)
        }

        guard let wholeImage = wholeImage else {
            assertionFailure("wholeImage not set")
            return
        }

        let rawImage = UIImage(contentsOfFile: wholeImage.imageURL.path)
        let image = rawImage?.normalizedOrientation()

        guard let image else {
            print("Failed to load or normalize image")
            return
        }

        heroUIImage = image
        heroAspectRatio = image.size.height / image.size.width

        DispatchQueue.main.async {
            self.collectionView.reloadSections(
                IndexSet(integer: MemorySection.hero.rawValue)
            )
        }

        let savedFaces = FaceStore.shared.loadFaces(for: wholeImage.wid)

        if !savedFaces.isEmpty {
            self.faces = savedFaces

            DispatchQueue.main.async {
                self.autoMatchFacesIfPossible()
                self.collectionView.reloadSections(
                    IndexSet(integer: MemorySection.people.rawValue)
                )
            }

            return
        }

        FaceDetectionService().detectFaces(
            in: image,
            imageID: wholeImage.wid
        ) { [weak self] detectedFaces in
            guard let self else { return }

            let existingFaces = FaceStore.shared.loadFaces(for: wholeImage.wid)

            let finalFaces = self.mergeFaces(
                detected: detectedFaces,
                existing: existingFaces
            )

            DispatchQueue.main.async {
                self.faces = finalFaces
                FaceStore.shared.saveFaces(finalFaces)
                
                self.autoMatchFacesIfPossible()

                self.collectionView.reloadSections(
                    IndexSet(integer: MemorySection.people.rawValue)
                )
            }
        }



    }
    
    private func mergeFaces(
        detected: [Face],
        existing: [Face]
    ) -> [Face] {

        var merged: [Face] = []

        for newFace in detected {
            if let oldFace = existing.first(where: {
                $0.orderIndex == newFace.orderIndex
            }) {
                merged.append(
                    Face(
                        fid: oldFace.fid,
                        faceImageURL: newFace.faceImageURL,
                        boundingBox: newFace.boundingBox,
                        orderIndex: newFace.orderIndex,
                        imageID: newFace.imageID,
                        personID: oldFace.personID
                    )
                )
            } else {
                merged.append(newFace)
            }
        }

        return merged
    }
    
    private func autoMatchFacesIfPossible() {
        
        var didUpdate = false

        for i in faces.indices where faces[i].personID == nil {

            guard
                let url = faces[i].faceImageURL,
                let image = UIImage(contentsOfFile: url.path),
                let embedding = FaceEmbedder.shared.embedding(from: image)
            else { continue }

            if let matchedPersonID =
                FaceNameMatcher.shared.matchPerson(for: embedding) {

                faces[i] = Face(
                    fid: faces[i].fid,
                    faceImageURL: faces[i].faceImageURL,
                    boundingBox: faces[i].boundingBox,
                    orderIndex: faces[i].orderIndex,
                    imageID: faces[i].imageID,
                    personID: matchedPersonID
                )

                didUpdate = true
            }
        }

        if didUpdate {
            FaceStore.shared.saveFaces(faces)
            collectionView.reloadSections(
                IndexSet(integer: MemorySection.people.rawValue)
            )
        }
    }



    
    private func registerCells() {
        collectionView.register(
            UINib(nibName: "HeroImageCell", bundle: nil),
            forCellWithReuseIdentifier: "HeroImageCell"
        )

        collectionView.register(
            UINib(nibName: "MemoryActionCell", bundle: nil),
            forCellWithReuseIdentifier: "MemoryActionCell"
        )

        collectionView.register(
            UINib(nibName: "PersonFaceCell", bundle: nil),
            forCellWithReuseIdentifier: "PersonFaceCell"
        )
        
        collectionView.register(
            UINib(nibName: "PeopleSectionHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "PeopleSectionHeaderView"
        )

    }
    
    private func createLayout() -> UICollectionViewLayout {

        return UICollectionViewCompositionalLayout { sectionIndex, _ in

            switch sectionIndex {

            case 0:
                return self.heroSection()

            case 1:
                return self.actionSection()

            case 2:
                return self.peopleSection()

            default:
                return nil
            }
        }
    }

    
    private func heroSection() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 8, leading: 8, bottom: 8, trailing: 8
        )

        return section
    }

    
    private func actionSection() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(180)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(180)
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 16, bottom: 0, trailing: 16
        )

        return section
    }
    
    private func peopleSection() -> NSCollectionLayoutSection {

        let columns: CGFloat = 3
        let spacing: CGFloat = 12

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / columns),
            heightDimension: .estimated(140)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        item.contentInsets = NSDirectionalEdgeInsets(
            top: spacing / 2,
            leading: spacing / 2,
            bottom: spacing / 2,
            trailing: spacing / 2
        )

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(140)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 16,
            bottom: 16,
            trailing: 16
        )
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [header]

        return section
    }
    
    private func deleteFace(_ face: Face, at indexPath: IndexPath) {

        if let url = face.faceImageURL {
            try? FileManager.default.removeItem(at: url)
        }

        faces.remove(at: indexPath.item)

        FaceStore.shared.saveFaces(faces)

        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [indexPath])
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {

        guard
            let info = notification.userInfo,
            let frame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        let keyboardHeight = frame.height

        collectionView.contentInset.bottom = keyboardHeight + 16
        collectionView.verticalScrollIndicatorInsets.bottom = keyboardHeight

        guard let indexPath = activeFaceIndexPath else { return }

        collectionView.scrollToItem(
            at: indexPath,
            at: .centeredVertically,
            animated: true
        )
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        collectionView.contentInset.bottom = 0
        collectionView.verticalScrollIndicatorInsets.bottom = 0
        activeFaceIndexPath = nil
    }



}

extension ImageDetailsViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return MemorySection.allCases.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        guard let sectionType = MemorySection(rawValue: section) else {
            return 0
        }

        switch sectionType {
        case .hero:
            return 1

        case .actions:
            return 1

        case .people:
            return faces.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let sectionType = MemorySection(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }

        switch sectionType {

        case .hero:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "HeroImageCell",
                for: indexPath
            ) as! HeroImageCell

            if let image = heroUIImage {
                cell.configure(image: image)
            } else {
                cell.configurePlaceholder()
            }

            return cell


        case .actions:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "MemoryActionCell",
                for: indexPath
            ) as! MemoryActionCell

            cell.configure(with: memoryActionContent)

            cell.onAddText = { [weak self] in
                self?.presentAddTextSheet()
            }

            cell.onEdit = { [weak self] in
                self?.presentEditTextSheet()
            }

            cell.onDelete = { [weak self] in
                guard let self = self,
                      var image = self.wholeImage else { return }

                image = WholeImage(
                    wid: image.wid,
                    imageURL: image.imageURL,
                    action: .empty,
                    createdAt: image.createdAt
                )

                self.wholeImage = image
                self.memoryActionContent = .empty

                LocalImageStore.shared.update(image)

                self.collectionView.reloadSections(
                    IndexSet(integer: MemorySection.actions.rawValue)
                )

                print("🗑 Text deleted & persisted")
            }

            
            cell.onAddVoice = { [weak self] in
                self?.presentVoiceRecorderSheet()
            }
            
            cell.onDeleteVoice = { [weak self] in
                guard let self = self,
                      var image = self.wholeImage else { return }

                // 🔥 1. Delete physical audio file
                if case let .voice(url) = image.action {
                    do {
                        try FileManager.default.removeItem(at: url)
                        print("🗑 Voice file removed from disk")
                    } catch {
                        print("❌ Failed to delete audio file:", error)
                    }
                }

                // 🔥 2. Update model
                image = WholeImage(
                    wid: image.wid,
                    imageURL: image.imageURL,
                    action: .empty,
                    createdAt: image.createdAt
                )

                self.wholeImage = image
                self.memoryActionContent = image.action!

                // 🔥 3. Persist
                LocalImageStore.shared.update(image)

                // 🔥 4. Refresh UI
                self.collectionView.reloadSections(
                    IndexSet(integer: MemorySection.actions.rawValue)
                )

                print("✅ Voice deleted & fully cleaned")
            }

            return cell


        case .people:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PersonFaceCell",
                for: indexPath
            ) as! PersonFaceCell

            let face = faces[indexPath.item]

            if let url = face.faceImageURL {
                cell.faceImageView.image = UIImage(contentsOfFile: url.path)
            }

            if let pid = face.personID,
               let person = PersonStore.shared.person(by: pid) {
                cell.nameLabel.text = person.name?.isEmpty == false
                    ? person.name
                    : "Add Name"
            } else {
                cell.nameLabel.text = "Add Name"
            }

            cell.onNameChanged = { [weak self] newName in
                guard let self else { return }

                let personID: UUID

                if let existingID = face.personID {
                    personID = existingID

                    if let existingPerson = PersonStore.shared.person(by: existingID) {
                        let updated = Person(
                            pid: existingID,
                            name: newName,
                            relationLabel: existingPerson.relationLabel
                        )
                        PersonStore.shared.add(updated)
                    }

                } else {
                    let newPerson = Person(
                        pid: UUID(),
                        name: newName,
                        relationLabel: nil
                    )
                    personID = newPerson.pid
                    PersonStore.shared.add(newPerson)
                }

                let updatedFace = Face(
                    fid: face.fid,
                    faceImageURL: face.faceImageURL,
                    boundingBox: face.boundingBox,
                    orderIndex: face.orderIndex,
                    imageID: face.imageID,
                    personID: personID
                )

                self.faces[indexPath.item] = updatedFace
                FaceStore.shared.saveFaces(self.faces)

                self.collectionView.reloadItems(at: [indexPath])
                
                if let url = face.faceImageURL,
                   let image = UIImage(contentsOfFile: url.path),
                   let embedding = FaceEmbedder.shared.embedding(from: image) {

                    PersonEmbeddingStore.shared.addEmbedding(
                        embedding,
                        for: personID
                    )
                } else {
                    print("Failed to generate embedding for named face")
                }
            }
            
            cell.nameTextField.addTarget(
                self,
                action: #selector(faceNameEditingBegan(_:)),
                for: .editingDidBegin
            )

            
            return cell
        }
    }
    
    @objc private func faceNameEditingBegan(_ textField: UITextField) {
        let point = textField.convert(CGPoint.zero, to: collectionView)
        activeFaceIndexPath = collectionView.indexPathForItem(at: point)
    }

    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader,
              indexPath.section == MemorySection.people.rawValue
        else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "PeopleSectionHeaderView",
            for: indexPath
        )

        return header
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {

        guard
            let section = MemorySection(rawValue: indexPath.section),
            section == .people
        else { return nil }

        let face = faces[indexPath.item]

        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath,
            previewProvider: nil
        ) { _ in

            let deleteAction = UIAction(
                title: "Delete Face",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self.deleteFace(face, at: indexPath)
            }

            return UIMenu(title: "", children: [deleteAction])
        }
    }
    
    private func presentAddTextSheet() {

        let vc = AddTextViewController(
            nibName: "AddTextViewController",
            bundle: nil
        )

        vc.modalPresentationStyle = .pageSheet

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [
                .custom { _ in 260 }
            ]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

//        vc.onSave = { [weak self] text in
//            guard let self else { return }
//
//            self.memoryActionContent = .text(text)
//
//            self.collectionView.reloadSections(
//                IndexSet(integer: MemorySection.actions.rawValue)
//            )
//        }
        
        vc.onSave = { [weak self] text in
            guard let self = self,
                  var image = self.wholeImage else { return }

            image = WholeImage(
                wid: image.wid,
                imageURL: image.imageURL,
                action: .text(text),
                createdAt: image.createdAt
            )

            self.wholeImage = image
            self.memoryActionContent = image.action!

            LocalImageStore.shared.update(image)

            self.collectionView.reloadSections(
                IndexSet(integer: MemorySection.actions.rawValue)
            )

            print("📝 Text persisted to album_metadata.json")
        }



        present(vc, animated: true)
    }
    
    private func presentEditTextSheet() {

        guard case .text(let existingText) = memoryActionContent else { return }

        let vc = AddTextViewController(
            nibName: "AddTextViewController",
            bundle: nil
        )

        vc.modalPresentationStyle = .pageSheet
        vc.prefilledText = existingText

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [
                .custom { _ in 260 }
            ]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

//        vc.onSave = { [weak self] text in
//            self?.memoryActionContent = .text(text)
//            self?.collectionView.reloadSections(
//                IndexSet(integer: MemorySection.actions.rawValue)
//            )
//        }
        
        vc.onSave = { [weak self] text in
            guard let self = self,
                  var image = self.wholeImage else { return }

            image = WholeImage(
                wid: image.wid,
                imageURL: image.imageURL,
                action: .text(text),
                createdAt: image.createdAt
            )

            self.wholeImage = image
            self.memoryActionContent = image.action!

            LocalImageStore.shared.update(image)

            self.collectionView.reloadSections(
                IndexSet(integer: MemorySection.actions.rawValue)
            )

            print("📝 Text persisted to album_metadata.json")
        }


        present(vc, animated: true)
    }
    
    private func presentVoiceRecorderSheet() {

        let vc = VoiceRecorderViewController(
            nibName: "VoiceRecorderViewController",
            bundle: nil
        )

        vc.modalPresentationStyle = .pageSheet

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [
                .custom { _ in 250 }
            ]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

//        vc.onRecordingFinished = { [weak self] url in
//            guard let self else { return }
//
//            self.memoryActionContent = .voice(url)
//
//            self.collectionView.reloadSections(
//                IndexSet(integer: MemorySection.actions.rawValue)
//            )
//        }
        
        vc.onRecordingFinished = { [weak self] url in
            guard let self = self,
                  var image = self.wholeImage else { return }

            image = WholeImage(
                wid: image.wid,
                imageURL: image.imageURL,
                action: .voice(url),
                createdAt: image.createdAt
            )

            self.wholeImage = image
            self.memoryActionContent = image.action!

            LocalImageStore.shared.update(image)

            self.collectionView.reloadSections(
                IndexSet(integer: MemorySection.actions.rawValue)
            )

            print("🎤 Voice persisted to album_metadata.json")
        }


        present(vc, animated: true)
    }




}


