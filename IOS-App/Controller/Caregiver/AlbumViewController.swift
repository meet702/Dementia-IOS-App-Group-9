//
//  AlbumViewController.swift
//  IOS-App
//
//  Created by SDC-USER on 02/02/26.
//

import UIKit

class AlbumViewController: UIViewController {

    @IBOutlet weak var albumCollectionView: UICollectionView!
    
    @IBOutlet weak var emptyStateView: UIView!
    
    private var images: [WholeImage] = []

    private let imagePicker = UIImagePickerController()
    
    private var selectedWholeImage: WholeImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumCollectionView.dataSource = self
        albumCollectionView.delegate = self
        albumCollectionView.register(UINib(nibName: "AlbumCell", bundle: nil), forCellWithReuseIdentifier: "AlbumCell")
        
        setupImagePicker()
        loadImages()
    }
    
    private func updateEmptyState() {
        let hasPhotos = !images.isEmpty

        emptyStateView.isHidden = hasPhotos
        albumCollectionView.isHidden = !hasPhotos

        if hasPhotos {
            view.bringSubviewToFront(albumCollectionView)
        } else {
            view.bringSubviewToFront(emptyStateView)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCollectionView()
    }

    private func setupCollectionView() {

        let layout = UICollectionViewFlowLayout()

        let columns: CGFloat = 3
        let spacing: CGFloat = 1
        let sectionInset: CGFloat = 1

        let totalSpacing = (columns - 1) * spacing
        let totalInsets = sectionInset * 2

        let availableWidth = albumCollectionView.bounds.width - totalSpacing - totalInsets
        let itemWidth = floor(availableWidth / columns)

        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(
            top: sectionInset,
            left: sectionInset,
            bottom: sectionInset,
            right: sectionInset
        )

        albumCollectionView.collectionViewLayout = layout
    }

    private func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
    }

    // MARK: - Data Loading

    private func loadImages() {
        images = LocalImageStore.shared
            .fetchAllImages()
            .filter { LocalImageStore.shared.fileExists(for: $0) }
            .sorted { $0.createdAt > $1.createdAt }

        albumCollectionView.reloadData()
        updateEmptyState()
    }

    // MARK: - Face Detection

    private func detectAndSaveFaces(for wholeImage: WholeImage, image: UIImage) {

        let existingFaces = FaceStore.shared.loadFaces(for: wholeImage.wid)
        guard existingFaces.isEmpty else {
            print("⏭ Faces already detected for image \(wholeImage.wid), skipping.")
            return
        }

        let normalizedImage = image.normalizedOrientation()
        print("🔍 Starting face detection for image: \(wholeImage.wid)")

        FaceDetectionService().detectFaces(
            in: normalizedImage,
            imageID: wholeImage.wid
        ) { detectedFaces in

            var facesWithPersonIDs = detectedFaces

            // ✅ Try auto-matching known faces via embeddings first
            for i in facesWithPersonIDs.indices {
                let url = FaceStore.shared.faceImageURL(for: facesWithPersonIDs[i].fileName)

                if let faceImage = UIImage(contentsOfFile: url.path),
                   let embedding = FaceEmbedder.shared.embedding(from: faceImage),
                   let matchedPersonID = FaceNameMatcher.shared.matchPerson(for: embedding) {

                    facesWithPersonIDs[i] = Face(
                        fid: facesWithPersonIDs[i].fid,
                        fileName: facesWithPersonIDs[i].fileName,
                        boundingBox: facesWithPersonIDs[i].boundingBox,
                        orderIndex: facesWithPersonIDs[i].orderIndex,
                        imageID: facesWithPersonIDs[i].imageID,
                        personID: matchedPersonID
                    )
                    print("✅ Auto-matched face \(i) to existing person: \(matchedPersonID)")
                }
            }

            // ✅ For any face still without a personID, create an anonymous person
            // This guarantees FaceVC always has questions to ask, even for unnamed people
            for i in facesWithPersonIDs.indices where facesWithPersonIDs[i].personID == nil {
                let anonymousPerson = Person(
                    pid: UUID(),
                    name: nil,
                    relationLabel: nil
                )
                PersonStore.shared.add(anonymousPerson)

                facesWithPersonIDs[i] = Face(
                    fid: facesWithPersonIDs[i].fid,
                    fileName: facesWithPersonIDs[i].fileName,
                    boundingBox: facesWithPersonIDs[i].boundingBox,
                    orderIndex: facesWithPersonIDs[i].orderIndex,
                    imageID: facesWithPersonIDs[i].imageID,
                    personID: anonymousPerson.pid
                )
                print("👤 Anonymous person created for face \(i): \(anonymousPerson.pid)")
            }

            FaceStore.shared.saveFaces(facesWithPersonIDs)
            print("✅ \(facesWithPersonIDs.count) face(s) saved with personIDs for image: \(wholeImage.wid)")
        }
    }

    // MARK: - Actions

    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
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

    // MARK: - Image Picker Helpers

    private func openPhotoLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }

    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true)
    }

    private func deleteImage(_ image: WholeImage, at indexPath: IndexPath) {

        // ✅ Only delete the main album image file + metadata
        // Do NOT delete face metadata or face images — they are needed
        // by ResponseDetailViewController to show person images in session history
        LocalImageStore.shared.deleteImage(image)

        // ✅ Update local array and animate removal
        images.remove(at: indexPath.item)

        albumCollectionView.performBatchUpdates {
            self.albumCollectionView.deleteItems(at: [indexPath])
        } completion: { _ in
            self.updateEmptyState()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {

        let image = images[indexPath.item]

        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath,
            previewProvider: nil
        ) { _ in

            let deleteAction = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self.deleteImage(image, at: indexPath)
            }

            return UIMenu(title: "", children: [deleteAction])
        }
    }
}

// MARK: - UICollectionViewDelegate + DataSource

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "AlbumCell",
            for: indexPath
        ) as! AlbumCell

        let image = images[indexPath.item]
        cell.configure(with: image)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !images.isEmpty else { return }

        let selectedImage = images[indexPath.item]
        selectedWholeImage = selectedImage
        performSegue(withIdentifier: "ShowImageDetails", sender: self)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension AlbumViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }

        // ✅ Save image and immediately trigger face detection in background
        let savedWholeImage = LocalImageStore.shared.saveImage(image)
        detectAndSaveFaces(for: savedWholeImage, image: image)

        loadImages()

        DispatchQueue.main.async {
            if self.images.count > 0 {
                self.albumCollectionView.scrollToItem(
                    at: IndexPath(item: 0, section: 0),
                    at: .top,
                    animated: false
                )
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowImageDetails",
              let destination = segue.destination as? ImageDetailsViewController,
              let selectedImage = selectedWholeImage
        else {
            return
        }

        destination.wholeImage = selectedImage
    }
}
