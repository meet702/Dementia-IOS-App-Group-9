//
//  CaregiverViewController.swift
//  Match the Pairs Test
//
//  Created by SDC-USER on 05/12/25.
//

import UIKit

class CaregiverViewController: UIViewController {

    @IBOutlet weak var albumButton: UIButton!

    private let routineRepository = RoutineRepository()
    private var selectedDate: Date = Date()
    
    func setupAlbumButton() {
        albumButton.setImage(UIImage(systemName: "photo.stack"), for: .normal)
        albumButton.layer.shadowColor = UIColor.black.cgColor
        albumButton.layer.shadowOpacity = 0.12
        albumButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        albumButton.layer.shadowRadius = 8
        albumButton.layer.masksToBounds = false
    }
    
    private let memoryManager = MemorySessionManager.shared

    var todaysSessions: [MemoryImageSession] {
        memoryManager.completedImageSessions
    }

    @IBOutlet weak var caregiverCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        caregiverCollectionView.dataSource = self
        setupAlbumButton()
        NotificationCenter.default.addObserver(self, selector: #selector(dataStoreUpdated(_:)), name: .DataStoreDidUpdateRoutines, object: nil)
        let layout = generateLayout()
        caregiverCollectionView.setCollectionViewLayout(layout, animated: true)
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleCollectionTap(_:))
        )

        tapGesture.cancelsTouchesInView = false
        caregiverCollectionView.addGestureRecognizer(tapGesture)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedDate = Date()
        caregiverCollectionView.reloadData()
    }

    @objc private func dataStoreUpdated(_ n: Notification) {
        DispatchQueue.main.async {
            let sectionIndex = 0
            let indexSet = IndexSet(integer: sectionIndex)
            self.caregiverCollectionView.reloadSections(indexSet)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleCollectionTap(_ gesture: UITapGestureRecognizer) {

        let location = gesture.location(in: caregiverCollectionView)

        guard let indexPath = caregiverCollectionView.indexPathForItem(at: location) else {
            return
        }

        guard indexPath.section == 0 else { return }

        
        let selectedSession = todaysSessions[indexPath.item]
        performSegue(
            withIdentifier: "showMemoryResponse",
            sender: selectedSession
        )

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // 🔹 Memory response flow
        if segue.identifier == "showMemoryResponse",
           let destination = segue.destination as? ResponseViewController,
           let session = sender as? MemoryImageSession {

            destination.session = session
            return
        }

        // 🔹 Caregiver → My Routine flow
        if segue.identifier == "showRoutine",
           let destination = segue.destination as? RoutineViewController {

            destination.userRole = .caregiver
            return
        }
    }

    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: {section, env in
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60))
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
            
            if section == 0 {

                let isEmpty = self.todaysSessions.isEmpty

                let section: NSCollectionLayoutSection

                if isEmpty {
                    // 🔵 EMPTY STATE (full-width, short)

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

                    section = NSCollectionLayoutSection(group: group)

                } else {
                    // 🟢 NORMAL STATE (restore original layout)

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

                    section = NSCollectionLayoutSection(group: group)
                    section.orthogonalScrollingBehavior = .groupPaging
                }

                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 5,
                    leading: 20,
                    bottom: 20,
                    trailing: 20
                )
                section.boundarySupplementaryItems = [headerItem]

                return section
            }

            else {
                
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
//                group.interItemSpacing = .fixed(10)

                let section = NSCollectionLayoutSection(group: group)
//                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 20, bottom: 20, trailing: 20)
                section.boundarySupplementaryItems = [headerItem]
                return section
            }
        }
        )
        return layout
    }
    func registerCell() {
        caregiverCollectionView.register(UINib(nibName: "RoutineCardCaregiver", bundle: nil), forCellWithReuseIdentifier: "routineCardCaregiver")
        caregiverCollectionView.register(UINib(nibName: "TodaySessionsCard", bundle: nil), forCellWithReuseIdentifier: "todaySessionsCard")
        caregiverCollectionView.register(UINib(nibName: "HeaderView", bundle: nil), forSupplementaryViewOfKind: "header", withReuseIdentifier: "header_cell")
        caregiverCollectionView.register(
            UINib(nibName: "EmptyStateCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "emptyStateCell"
        )
    }

}

extension CaregiverViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return todaysSessions.isEmpty ? 1 : todaysSessions.count
        }
        else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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

            // 🔹 NORMAL SESSION CELL
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "todaySessionsCard",
                for: indexPath
            ) as! TodaySessionsCard

            let todaySession = todaysSessions[indexPath.row]
            cell.configureTodaysSession(todaysSession: todaySession)

            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "routineCardCaregiver", for: indexPath) as! RoutineCardCaregiver
            let tasks = routineRepository.fetchTasks(for: selectedDate)
            cell.configureRoutineCell(tasks: tasks, date: selectedDate)
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // Create the header view
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: "header_cell", for: indexPath) as! HeaderView
        if indexPath.section == 0 {
            headerView.configureHeaderCell(text: "Session History", showChevron: false, isTappable: false)
            
        }
        else {
            headerView.configureHeaderCell(text: "Arjun's Routine",
                                           showChevron: true,
                                           isTappable: true,
                                           onTap: { [weak self] in
                                               self?.performSegue(withIdentifier: "showRoutine", sender: nil)
                                           }
            )
        }
        return headerView
    }
    
}
