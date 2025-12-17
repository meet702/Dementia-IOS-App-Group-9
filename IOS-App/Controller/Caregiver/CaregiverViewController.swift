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
    
    var todaysSessions: [ImageSession] {
        ResponseDataStore.shared.imageSession
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

        guard indexPath.section == 1 else { return }

        let selectedSession = todaysSessions[indexPath.item]

        ResponseDataStore.shared.currentImageSession = selectedSession

        performSegue(withIdentifier: "showMemoryResponse", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard segue.identifier == "showMemoryResponse" else { return }

        if let destination = segue.destination as? ResponseViewController {
            destination.session = ResponseDataStore.shared.currentImageSession
            print("Prepared Memory Response via segue")
        }
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
