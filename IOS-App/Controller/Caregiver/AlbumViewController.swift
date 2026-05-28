import UIKit
import Supabase

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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRestoreComplete),
            name: .didRestoreFromSupabase,
            object: nil
        )
    }

    @objc private func handleRestoreComplete() {
        DispatchQueue.main.async {
            self.loadImages()
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
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

    private func loadImages() {
        images = LocalImageStore.shared
            .fetchAllImages()
            .sorted { $0.createdAt > $1.createdAt }

        DispatchQueue.main.async {
            self.albumCollectionView.reloadData()
            self.updateEmptyState()
        }
    }

    private func detectAndSaveFaces(for wholeImage: WholeImage, image: UIImage) {
        let existingFaces = FaceStore.shared.loadFaces(for: wholeImage.wid)

        if !existingFaces.isEmpty {
            Task {
                await SupabaseSyncManager.shared.upsertFaces(existingFaces)
                await SupabaseSyncManager.shared.uploadFaceImages(existingFaces)
            }
            return
        }

        let normalizedImage = image.normalizedOrientation()

        FaceDetectionService().detectFaces(
            in: normalizedImage,
            imageID: wholeImage.wid
        ) { detectedFaces in
            FaceStore.shared.saveFaces(detectedFaces)
            Task {
                await SupabaseSyncManager.shared.upsertFaces(detectedFaces)
                await SupabaseSyncManager.shared.uploadFaceImages(detectedFaces)
            }
        }
    }

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

        LocalImageStore.shared.deleteImage(image)
        Task {
            await SupabaseSyncManager.shared.deleteWholeImage(wid: image.wid)
        }

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

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "AlbumCell",
            for: indexPath
        ) as? AlbumCell else {
            return UICollectionViewCell()
        }

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

extension AlbumViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }

        let savedWholeImage = LocalImageStore.shared.saveImage(image)

        Task {
            await SupabaseSyncManager.shared.insertWholeImage(savedWholeImage)

            DispatchQueue.main.async {
                self.detectAndSaveFaces(for: savedWholeImage, image: image)
            }
        }

        loadImages()

        DispatchQueue.main.async {
            if !self.images.isEmpty {
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
