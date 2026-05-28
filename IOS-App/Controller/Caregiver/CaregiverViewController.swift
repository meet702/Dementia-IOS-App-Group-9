import UIKit

final class CaregiverViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var caregiverCollectionView: UICollectionView!

    private let routineRepository = RoutineStore.shared
    private let sessionStore = ImageSessionStore.shared

    private var selectedDate: Date = Date()
    var firstName: String {
        let fullName = SessionManager.shared.patientName ?? "Patient"
        return fullName.components(separatedBy: " ").first ?? fullName
    }

    var todaysSessions: [ImageSession] {
        sessionStore.sessionsForToday()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell()
        caregiverCollectionView.dataSource = self
        caregiverCollectionView.delegate = self

        setupAlbumButton()

        let layout = generateLayout()
        caregiverCollectionView.setCollectionViewLayout(layout, animated: true)

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleCollectionTap(_:))
        )
        tapGesture.cancelsTouchesInView = false
        caregiverCollectionView.addGestureRecognizer(tapGesture)

        if LocalImageStore.shared.fetchAllImages().isEmpty {

            Task { [weak self] in
                await SupabaseSyncManager.shared.restoreCaregiverMemories()

                await MainActor.run {
                    self?.caregiverCollectionView.reloadData()
                }
            }

        }
        SessionManager.shared.loadFromDefaults()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedDate = Date()
        let fullName = SessionManager.shared.caregiverName ?? "Caregiver"
        let caregiverFirstName = fullName.components(separatedBy: " ").first ?? fullName

        navigationItem.title = "Hello \(caregiverFirstName)"
        caregiverCollectionView.reloadData()
    }

    private func registerCell() {
        caregiverCollectionView.register(
            UINib(nibName: "RoutineCardCaregiver", bundle: nil),
            forCellWithReuseIdentifier: "routineCardCaregiver"
        )

        caregiverCollectionView.register(
            UINib(nibName: "TodaySessionsCard", bundle: nil),
            forCellWithReuseIdentifier: "todaySessionsCard"
        )

        caregiverCollectionView.register(
            UINib(nibName: "HeaderView", bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "header_cell"
        )

        caregiverCollectionView.register(
            UINib(nibName: "EmptyStateCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "emptyStateCell"
        )
    }

    private func generateLayout() -> UICollectionViewLayout {

        UICollectionViewCompositionalLayout { [weak self] section, _ in
            guard let self = self else { return nil }

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(60)
            )

            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: "header",
                alignment: .top
            )

            if section == 0 {

                let isEmpty = self.todaysSessions.isEmpty
                let layoutSection: NSCollectionLayoutSection

                if isEmpty {
                    let itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(96)
                    )
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)

                    let groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(96)
                    )
                    let group = NSCollectionLayoutGroup.vertical(
                        layoutSize: groupSize,
                        subitems: [item]
                    )

                    layoutSection = NSCollectionLayoutSection(group: group)

                } else {
                    let itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(1.0)
                    )
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)

                    let groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.37),
                        heightDimension: .absolute(148)
                    )
                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: groupSize,
                        subitems: [item]
                    )
                    group.interItemSpacing = .fixed(10)

                    layoutSection = NSCollectionLayoutSection(group: group)
                    layoutSection.orthogonalScrollingBehavior = .groupPaging
                }

                layoutSection.interGroupSpacing = 10
                layoutSection.contentInsets = NSDirectionalEdgeInsets(
                    top: 5,
                    leading: 20,
                    bottom: 20,
                    trailing: 20
                )
                layoutSection.boundarySupplementaryItems = [headerItem]

                return layoutSection
            }

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(200)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(200)
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )

            let layoutSection = NSCollectionLayoutSection(group: group)
            layoutSection.contentInsets = NSDirectionalEdgeInsets(
                top: 5,
                leading: 20,
                bottom: 20,
                trailing: 20
            )
            layoutSection.boundarySupplementaryItems = [headerItem]

            return layoutSection
        }
    }

    private func setupAlbumButton() {
        albumButton.setImage(UIImage(systemName: "photo.stack"), for: .normal)
        albumButton.layer.shadowColor = UIColor.black.cgColor
        albumButton.layer.shadowOpacity = 0.12
        albumButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        albumButton.layer.shadowRadius = 8
        albumButton.layer.masksToBounds = false
    }

    @objc private func handleCollectionTap(_ gesture: UITapGestureRecognizer) {

        let location = gesture.location(in: caregiverCollectionView)

        guard let indexPath = caregiverCollectionView.indexPathForItem(at: location),
              indexPath.section == 0,
              !todaysSessions.isEmpty
        else { return }

        let selectedSession = todaysSessions[indexPath.item]
        performSegue(withIdentifier: "showMemoryResponse", sender: selectedSession)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showMemoryResponse",
           let destination = segue.destination as? ResponseViewController,
           let session = sender as? ImageSession {

            destination.imageSession = session
            return
        }

        if segue.identifier == "showRoutine",
           let destination = segue.destination as? RoutineViewController {
            destination.caregiverTitle = "\(firstName)'s Routine"
            destination.userRole = .caregiver
            return
        }
    }
}

extension CaregiverViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return todaysSessions.isEmpty ? 1 : todaysSessions.count
        } else {
            return 1
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        if indexPath.section == 0 {

            if todaysSessions.isEmpty {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "emptyStateCell",
                    for: indexPath
                ) as! EmptyStateCollectionViewCell

                cell.configure(
                    title: "No activity yet",
                    subtitle: "Patient hasn’t completed any sessions today"
                )
                return cell
            }

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "todaySessionsCard",
                for: indexPath
            ) as! TodaySessionsCard

            let session = todaysSessions[indexPath.item]
            cell.configure(imageSession: session)

            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "routineCardCaregiver",
            for: indexPath
        ) as! RoutineCardCaregiver

        let tasks = routineRepository.fetchTasks(for: selectedDate)
        cell.configureRoutineCell(tasks: tasks, date: selectedDate)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: "header_cell", for: indexPath) as! HeaderView
        if indexPath.section == 1 {
            headerView.configureHeaderCell(text: "\(firstName)'s Routine",
                                           showChevron: true,
                                           isTappable: true,
                                           onTap: { [weak self] in
                                               self?.performSegue(withIdentifier: "showRoutine", sender: nil)
                                           }
            )
        } else {
            headerView.configureHeaderCell(text: "Session History", showChevron: false, isTappable: false)
        }
        return headerView
    }
}
