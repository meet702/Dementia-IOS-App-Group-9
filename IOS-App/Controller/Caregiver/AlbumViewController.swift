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
//        print("📂 Documents path:",
//        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])

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
            .filter { LocalImageStore.shared.fileExists(for: $0) }.sorted { $0.createdAt > $1.createdAt }


        albumCollectionView.reloadData()
        updateEmptyState()
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

        // Remove from disk + metadata
        LocalImageStore.shared.deleteImage(image)

        // Update local array
        images.remove(at: indexPath.item)

        // Animate removal
        albumCollectionView.performBatchUpdates {
            albumCollectionView.deleteItems(at: [indexPath])
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


        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "AlbumCell",
            for: indexPath
        ) as! AlbumCell

        let image = images[indexPath.item]
        let url = LocalImageStore.shared.fileURL(for: image)

        if let uiImage = UIImage(contentsOfFile: url.path) {
            cell.configure(with: image)
        } else {
            print("❌ Failed loading image at:", url.path)
            cell.configure(with: image) // or placeholder
        }

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
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }

        LocalImageStore.shared.saveImage(image)
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
