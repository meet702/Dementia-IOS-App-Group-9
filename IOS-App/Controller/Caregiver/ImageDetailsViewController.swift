import UIKit
import Supabase

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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func reloadActionSection() {
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadSections(IndexSet(integer: MemorySection.actions.rawValue))
    }

    private func loadHeroImageAndDetectFaces() {

        if let id = wholeImage?.wid,
           let stored = LocalImageStore.shared.fetchImageModel(by: id) {

            self.wholeImage = stored
            self.memoryActionContent = stored.action ?? .empty

        }

        guard let wholeImage = wholeImage else {
            assertionFailure("wholeImage not set")
            return
        }

        let rawImage = LocalImageStore.shared.fetchImage(by: wholeImage.wid)
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
            self.faces = savedFaces.sorted { $0.orderIndex < $1.orderIndex }
            for face in self.faces {
                let url = FaceStore.shared.faceImageURL(for: face.fileName)
            }

            DispatchQueue.main.async {
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
            let finalFaces = self.mergeFaces(detected: detectedFaces, existing: existingFaces)

            DispatchQueue.main.async {
                self.faces = finalFaces
                FaceStore.shared.saveFaces(finalFaces)
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
                        fileName: newFace.fileName,
                        boundingBox: newFace.boundingBox,
                        orderIndex: newFace.orderIndex,
                        wid: newFace.wid,
                        personName: oldFace.personName
                    )
                )
            } else {
                merged.append(newFace)
            }
        }

        return merged
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

        let url = FaceStore.shared.faceImageURL(for: face.fileName)
        try? FileManager.default.removeItem(at: url)

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
                guard let self,
                      let image = self.wholeImage else { return }

                let updated = WholeImage(
                    wid: image.wid,
                    fileName: image.fileName,
                    action: .empty,
                    createdAt: image.createdAt
                )

                LocalImageStore.shared.update(updated)

                Task {
                    do {
                        try await SupabaseManager.shared.client
                            .from("WholeImage")
                            .update([
                                "action": updated.action ?? MemoryActionContent.empty
                            ])
                            .eq("wid", value: image.wid)
                            .execute()

                    } catch {
                        print("Supabase WholeImage update failed:", error)
                    }
                }

                self.wholeImage = updated
                self.memoryActionContent = updated.action ?? .empty

                self.reloadActionSection()

            }

            cell.onAddVoice = { [weak self] in
                self?.presentVoiceRecorderSheet()
            }

            cell.onDeleteVoice = { [weak self] in
                guard let self,
                      let image = self.wholeImage else { return }

                if case let .voice(url) = image.action {
                    do {
                        try FileManager.default.removeItem(at: url)
                    } catch {
                        print("Failed to delete audio file:", error)
                    }
                }

                let updated = WholeImage(
                    wid: image.wid,
                    fileName: image.fileName,
                    action: .empty,
                    createdAt: image.createdAt
                )

                LocalImageStore.shared.update(updated)
                Task {
                    do {
                        try await SupabaseManager.shared.client
                            .from("WholeImage")
                            .update([
                                "action": updated.action ?? MemoryActionContent.empty
                            ])
                            .eq("wid", value: image.wid)
                            .execute()

                    } catch {
                        print("Supabase WholeImage update failed:", error)
                    }
                }

                self.wholeImage = updated
                self.memoryActionContent = updated.action ?? .empty

                self.reloadActionSection()

            }

            return cell

        case .people:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PersonFaceCell",
                for: indexPath
            ) as! PersonFaceCell

            let face = faces[indexPath.item]

            let url = FaceStore.shared.faceImageURL(for: face.fileName)

            if FileManager.default.fileExists(atPath: url.path) {
                cell.faceImageView.image = UIImage(contentsOfFile: url.path)
            } else {
                cell.faceImageView.image = UIImage(systemName: "person.crop.circle.fill")
            }

            if let name = face.personName,
               !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                cell.nameLabel.text = name
            } else {
                cell.nameLabel.text = "Add Name"
            }

            cell.onNameChanged = { [weak self] newName in
                guard let self else { return }

                var updatedFace = face
                updatedFace = Face(
                    fid: face.fid,
                    fileName: face.fileName,
                    boundingBox: face.boundingBox,
                    orderIndex: face.orderIndex,
                    wid: face.wid,
                    personName: newName
                )

                self.faces[indexPath.item] = updatedFace
                FaceStore.shared.saveFaces(self.faces)

                Task {
                    await SupabaseSyncManager.shared.upsertFaces([updatedFace])
                }

                self.collectionView.reloadItems(at: [indexPath])
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

        vc.onSave = { [weak self] text in
            guard let self,
                  let image = self.wholeImage else { return }

            let updated = WholeImage(
                wid: image.wid,
                fileName: image.fileName,
                action: .text(text),
                createdAt: image.createdAt
            )

            LocalImageStore.shared.update(updated)

            Task {
                await SupabaseSyncManager.shared.updateWholeImageAction(
                    wid: image.wid,
                    action: updated.action ?? .empty
                )
            }

            self.wholeImage = updated
            self.memoryActionContent = updated.action ?? .empty

            self.reloadActionSection()

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

        vc.onSave = { [weak self] text in
            guard let self,
                  let image = self.wholeImage else { return }

            let updated = WholeImage(
                wid: image.wid,
                fileName: image.fileName,
                action: .text(text),
                createdAt: image.createdAt
            )

            LocalImageStore.shared.update(updated)

            Task {
                await SupabaseSyncManager.shared.updateWholeImageAction(
                    wid: image.wid,
                    action: updated.action ?? .empty
                )
            }

            self.wholeImage = updated
            self.memoryActionContent = updated.action ?? .empty

            self.reloadActionSection()

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

        vc.onRecordingFinished = { [weak self] url in
            guard let self,
                  let image = self.wholeImage else { return }

            let updated = WholeImage(
                wid: image.wid,
                fileName: image.fileName,
                action: .voice(url),
                createdAt: image.createdAt
            )

            LocalImageStore.shared.update(updated)

            Task {
                await SupabaseSyncManager.shared.updateWholeImageAction(
                    wid: image.wid,
                    action: updated.action ?? .empty
                )
            }

            self.wholeImage = updated
            self.memoryActionContent = updated.action ?? .empty

            self.reloadActionSection()

        }

        present(vc, animated: true)
    }
}
