//
//  CaregiverViewController.swift
//  Match the Pairs Test
//
//  Created by SDC-USER on 05/12/25.
//

import UIKit

class CaregiverViewController: UIViewController {

    @IBOutlet weak var albumButton: UIButton!

    private var selectedDate: Date = Date()
    
    func setupAlbumButton() {
        albumButton.setImage(UIImage(systemName: "photo.stack"), for: .normal)
        albumButton.layer.shadowColor = UIColor.black.cgColor
        albumButton.layer.shadowOpacity = 0.12
        albumButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        albumButton.layer.shadowRadius = 8
        albumButton.layer.masksToBounds = false
    }
    
    
    
    @IBOutlet weak var caregiverCollectionView: UICollectionView!
    
    var completedTask: [RoutineCardModel] = [
        RoutineCardModel(title: "Brush teeth", subtitle: "", timeText: "7:45 AM"),
        RoutineCardModel(title: "Have Breakfast", subtitle: "", timeText: "8:00 AM")
    ]
    var pendingTask: [RoutineCardModel] = [
        RoutineCardModel(title: "Take meds", subtitle: "Vitamin B12 - 1 capsule", timeText: "8:45 AM")
    ]
    
    var todaysSessions: [TodaysSessionCardModel] = [
        TodaysSessionCardModel(date: "3 Oct, 2025",
                               time: "8:05 AM"
                              ,imageName: "image 42"),
        TodaysSessionCardModel(date: "3 Oct, 2025",
                               time: "8:25 AM",
                              imageName: "image 43"),
        TodaysSessionCardModel(date: "2 Oct, 2025",
                               time: "6:23 PM"
                              ,imageName: "image 67"),
        TodaysSessionCardModel(date: "2 Oct, 2025",
                               time: "10:15 AM",
                              imageName: "image 68"),
        TodaysSessionCardModel(date: "31 Sept, 2025",
                               time: "4:46 PM",
                              imageName: "image 69"),
        TodaysSessionCardModel(date: "30 Sept, 2025",
                               time: "9:07 AM",
                              imageName: "image 70")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        caregiverCollectionView.dataSource = self
        setupAlbumButton()
        NotificationCenter.default.addObserver(self, selector: #selector(dataStoreUpdated(_:)), name: .DataStoreDidUpdateRoutines, object: nil)
        let layout = generateLayout()
        caregiverCollectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ensure the Home card shows today's tasks by default
        selectedDate = Date()
        // refresh the layout/data so the Routine card reads the correct date
        caregiverCollectionView.reloadData()
    }

    @objc private func dataStoreUpdated(_ n: Notification) {
        DispatchQueue.main.async {
            // If DataStore sends a "dateKey" in userInfo you can check it here and only reload when it matches.
            // For simplicity we reload only the "My Routine" section (section index 2).
            let sectionIndex = 0
            let indexSet = IndexSet(integer: sectionIndex)
            self.caregiverCollectionView.reloadSections(indexSet)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: {section, env in
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60))
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
            
            if section == 0 {
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
            else {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.37), heightDimension: .absolute(148))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(10)
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 20, bottom: 20, trailing: 20)

                section.orthogonalScrollingBehavior = .groupPaging
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
        
    }

}

extension CaregiverViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return todaysSessions.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "routineCardCaregiver", for: indexPath) as! RoutineCardCaregiver
            let tasks = DataStore.shared.getRoutines(for: selectedDate)
            cell.configureRoutineCell(tasks: tasks, date: Date())
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "todaySessionsCard", for: indexPath) as! TodaySessionsCard
            let todaySessions = todaysSessions[indexPath.row]
            cell.configureTodaysSession(todaysSession: todaySessions)
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // Create the header view
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: "header_cell", for: indexPath) as! HeaderView
        if indexPath.section == 0 {
            headerView.configureHeaderCell(text: "Arjun's Routine",
                                           showChevron: true,
                                           isTappable: true,
                                           onTap: { [weak self] in
                                               self?.performSegue(withIdentifier: "showRoutine", sender: nil)
                                           }
            )
        }
        else {
            headerView.configureHeaderCell(text: "Session History", showChevron: false, isTappable: false)
        }
        return headerView
    }
    
}
