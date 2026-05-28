import UIKit
import CoreLocation

class HomeViewController: UIViewController {

    @IBOutlet weak var homeCollectionView: UICollectionView!
    @IBOutlet weak var sosButton: UIBarButtonItem!

    private let routineRepository = RoutineStore.shared
    private var selectedDate: Date = Date()

    var brainBoosters: [BrainBoostersCardModel] = [
        BrainBoostersCardModel(gameName: "Match the Pairs", gameImage: "Group 355"),
        BrainBoostersCardModel(gameName: "Sudoku", gameImage: "Group 354"),
        BrainBoostersCardModel(gameName: "Crossword", gameImage: "Group 353")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = timeBasedGreeting()
        registerCell()
        homeCollectionView.dataSource = self
        homeCollectionView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(dataStoreUpdated(_:)), name: .DataStoreDidUpdateRoutines, object: nil)
        let layout = generateLayout()
        homeCollectionView.setCollectionViewLayout(layout, animated: true)

        Task {
            await SupabaseSyncManager.shared.uploadMissingFaceImages()
        }

    }

    private var loadingOverlay: UIView?

    private func showRestoreLoadingIndicator() {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.systemBackground
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()

        let label = UILabel()
        label.text = "Restoring your memories..."
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [spinner, label])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        overlay.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        ])

        view.addSubview(overlay)
        loadingOverlay = overlay
    }

    private func hideRestoreLoadingIndicator() {
        loadingOverlay?.removeFromSuperview()
        loadingOverlay = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedDate = Date()
        homeCollectionView.reloadData()
    }

    @objc private func dataStoreUpdated(_ n: Notification) {
        DispatchQueue.main.async {
            let sectionIndex = 2
            let indexSet = IndexSet(integer: sectionIndex)
            self.homeCollectionView.reloadSections(indexSet)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func latestMemoryImage() -> UIImage? {

        let allImages = LocalImageStore.shared.fetchAllImages()
            .sorted { $0.createdAt > $1.createdAt }

        guard !allImages.isEmpty else { return nil }

        let allSessions = ImageSessionStore.shared.allSessions()

        let playCountByImage: [UUID: Int] = allImages.reduce(into: [:]) { counts, image in
            counts[image.wid] = allSessions.filter { $0.wid == image.wid }.count
        }

        let minPlayCount = allImages.map { playCountByImage[$0.wid, default: 0] }.min() ?? 0

        let nextImage = allImages.first(where: {
            (playCountByImage[$0.wid] ?? 0) == minPlayCount
        }) ?? allImages.first

        return nextImage.flatMap { LocalImageStore.shared.fetchImage(by: $0.wid) }
    }

    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: {section, _ in

            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)

            if section == 0 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(220))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(10)

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: -15, leading: 20, bottom: 20, trailing: 20)

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70))
                let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
                section.boundarySupplementaryItems = [headerItem]
                return section
            } else if section == 1 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.9))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(10)

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: -25, leading: 20, bottom: -10, trailing: 20)

                return section
            } else if section == 2 {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(200)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(200)
                )
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)

                section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 20, bottom: 20, trailing: 20)
                section.boundarySupplementaryItems = [headerItem]
                return section
            } else {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6), heightDimension: .fractionalHeight(0.35))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(10)

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 23
                section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 23, bottom: 12, trailing: 20)

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
                let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)

                section.orthogonalScrollingBehavior = .groupPaging
                section.boundarySupplementaryItems = [headerItem]
                return section
            }
        }
        )
        return layout
    }

    func registerCell() {
        homeCollectionView.register(UINib(nibName: "MemoryRecapCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "memoryRecapCardCollectionViewCell")

        homeCollectionView.register(UINib(nibName: "MemoryLaneCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "memoryLaneCardCollectionViewCell")

        homeCollectionView.register(UINib(nibName: "HeaderView", bundle: nil), forSupplementaryViewOfKind: "header", withReuseIdentifier: "header_cell")

        homeCollectionView.register(UINib(nibName: "BrainBoostersCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "brainBoostersCardCollectionViewCell")

        homeCollectionView.register(UINib(nibName: "RoutineCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "routineCardCollectionViewCell")
    }

    private func timeBasedGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<21:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }

    private func hasUnplayedMemory() -> Bool {
        guard
            let latestImage = LocalImageStore.shared
                .fetchAllImages()
                .sorted(by: { $0.createdAt > $1.createdAt })
                .first,
            let lastSession = ImageSessionStore.shared
                .latestMemoryLaneSession()
        else {
            return false
        }

        return latestImage.createdAt > lastSession.startedAt
    }

    private func launchMemoryRecap() {

        let allSessions = ImageSessionStore.shared.allSessions()
            .sorted { $0.startedAt < $1.startedAt }

        guard !allSessions.isEmpty else {
            let alert = UIAlertController(
                title: "No Memories Yet",
                message: "No sessions have been played yet.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let allImages = LocalImageStore.shared.fetchAllImages()

        guard let nextImageID = MemoryRecapManager.shared.nextImageID(from: allImages) else {

            let alert = UIAlertController(
                title: "No Recaps Yet",
                message: "Start with a Memory Lane activity to explore a memory. After that, you can revisit it here.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)

            return
        }

        guard let nextSession = allSessions.first(where: {
            $0.wid == nextImageID
        }) else {
            return
        }

        let wholeImage: WholeImage
        if let stored = LocalImageStore.shared.fetchImageModel(by: nextSession.wid) {
            wholeImage = stored
        } else {
            wholeImage = WholeImage(
                wid: nextSession.wid,
                fileName: "",
                action: .empty,
                createdAt: nextSession.startedAt
            )
        }

        guard let portraitImage = SessionImageStore.shared.fetchImage(by: nextSession.wid)
                               ?? LocalImageStore.shared.fetchImage(by: nextSession.wid)
        else {
            return
        }

        let faces = FaceStore.shared.loadFaces(for: nextSession.wid)

        let storyboard = UIStoryboard(name: "MemoryLane", bundle: nil)

        guard let faceVC = storyboard.instantiateViewController(
            withIdentifier: "FaceViewController"
        ) as? FaceViewController else { return }

        faceVC.sessionMode = .recap
        faceVC.recapImageSession = nextSession
        faceVC.wholeImage = wholeImage
        faceVC.faces = faces
        faceVC.portraitImage = portraitImage
        faceVC.questionsByPerson = [:]

        navigationController?.pushViewController(faceVC, animated: true)
    }

}

extension HomeViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return 1
        } else {
            return brainBoosters.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memoryLaneCardCollectionViewCell", for: indexPath) as? MemoryLaneCardCollectionViewCell else {
                return UICollectionViewCell()
            }
            let latestImage = latestMemoryImage()
            if latestImage == nil {
                    cell.configureMemoryLaneCell(
                        image: UIImage(named: "photo_placeholder"),
                        title: "Memory Lane",
                        subtitle: "You can begin when memories are added."
                    )
                    cell.showNewBadge(false)
                } else {
                    cell.configureMemoryLaneCell(image: latestImage)
                    cell.showNewBadge(hasUnplayedMemory())
                }

                return cell
        } else if indexPath.section == 1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memoryRecapCardCollectionViewCell", for: indexPath) as? MemoryRecapCardCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configureMemoryRecapCardCell()
            return cell
        } else if indexPath.section == 2 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "routineCardCollectionViewCell", for: indexPath) as? RoutineCardCollectionViewCell else {
                return UICollectionViewCell()
            }
            let tasks = routineRepository.fetchTasks(for: selectedDate)
            cell.configureRoutineCell(tasks: tasks, date: selectedDate)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "brainBoostersCardCollectionViewCell", for: indexPath) as? BrainBoostersCardCollectionViewCell else {
                return UICollectionViewCell()
            }
            let brainBoosters = brainBoosters[indexPath.row]
            cell.configureBrainBoostersCell(brainBooster: brainBoosters)
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header_cell", for: indexPath) as? HeaderView else {
            return UICollectionReusableView()
        }
        if indexPath.section == 0 {
            headerView.configureHeaderCell(text: "Memories", showChevron: false, isTappable: false)
        } else if indexPath.section == 1 {
            headerView.configureHeaderCell(text: "Memory Recap", showChevron: false, isTappable: false)
        } else if indexPath.section == 2 {
            headerView.configureHeaderCell(text: "My Routine",
                                           showChevron: true,
                                           isTappable: true,
                                           onTap: { [weak self] in
                                               self?.performSegue(withIdentifier: "showRoutine", sender: nil)
                                           }
            )
        } else {
            headerView.configureHeaderCell(text: "Brain Boosters", showChevron: false, isTappable: false)
        }
        return headerView
    }

}

extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let images = LocalImageStore.shared.fetchAllImages()
            guard !images.isEmpty else {
                let alert = UIAlertController(
                    title: "No Memories Yet",
                    message: "Please ask your family member to add a memory first.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }

            performSegue(withIdentifier: "showMemoryLane", sender: nil)
            return
        }

        if indexPath.section == 1 {
            launchMemoryRecap()
            return
        }

        if indexPath.section == 3 {
            guard indexPath.item >= 0, indexPath.item < brainBoosters.count else { return }

            let model = brainBoosters[indexPath.item]
            let name = model.gameName.lowercased()

            if name.contains("sudoku") {
                performSegue(withIdentifier: "showSudokuInstructions", sender: model)
                return
            }

            if name.contains("match the pairs") {
                performSegue(withIdentifier: "showMatchThePairsInstructions", sender: model)
                return
            }

            if name.contains("crossword") {
                performSegue(withIdentifier: "showCrosswordInstructions", sender: model)
                return
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? BrainBoostersCardModel {
            if segue.identifier == "showSudokuInstructions",
               let _ = segue.destination as? MatchThePairsInstructionsViewController {

            } else if segue.identifier == "showMatchThePairsInstructions",
                let _ = segue.destination as? MatchThePairsInstructionsViewController {

            } else if segue.identifier == "showCrosswordInstructions",
                let _ = segue.destination as? MatchThePairsInstructionsViewController {

            }
            return
        }

        if segue.identifier == "showMemoryRecap" {
            if let _ = segue.destination as? UIViewController {
            }
        }

    }
}

extension Notification.Name {
    static let didRestoreFromSupabase = Notification.Name("didRestoreFromSupabase")
}
