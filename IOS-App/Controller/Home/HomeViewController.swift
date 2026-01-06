//
//  ViewController.swift
//  Home-Test
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var homeCollectionView: UICollectionView!
    
    private var selectedDate: Date = Date()
    
    var brainBoosters: [BrainBoostersCardModel] = [
        BrainBoostersCardModel(gameName: "Match the Pairs", gameImage: "Group 355"),
        BrainBoostersCardModel(gameName: "Sudoku", gameImage: "Group 354"),
        BrainBoostersCardModel(gameName: "Crossword", gameImage: "Group 353")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        registerCell()
        homeCollectionView.dataSource = self
        homeCollectionView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(dataStoreUpdated(_:)), name: .DataStoreDidUpdateRoutines, object: nil)
        let layout = generateLayout()
        homeCollectionView.setCollectionViewLayout(layout, animated: true)
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
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: {section, env in
            
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
            }
            else if section == 1 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.9))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(10)
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: -25, leading: 20, bottom: -10, trailing: 20)
//                section.boundarySupplementaryItems = [headerItem]
                return section
            }
            
            else if section == 2 {
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
    
    
    @IBAction func sosButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "Contact Your Caregiver?",
            message: "A call and your location will be sent to your caregiver.",
            preferredStyle: .alert
        )

        let helpAction = UIAlertAction(title: "Yes, Get help", style: .default) { _ in
            self.triggerSOS()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(helpAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
    
    private func triggerSOS() {
        print("SOS triggered")
    }

}

extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return 1
        }
        else if section == 2{
            return 1
        }
        else {
            return brainBoosters.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memoryLaneCardCollectionViewCell", for: indexPath) as! MemoryLaneCardCollectionViewCell
            cell.configureMemoryLaneCell()
            return cell
        }
        else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memoryRecapCardCollectionViewCell", for: indexPath) as! MemoryRecapCardCollectionViewCell
            cell.configureMemoryRecapCardCell()
            return cell
        }
        
        else if indexPath.section == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "routineCardCollectionViewCell", for: indexPath) as! RoutineCardCollectionViewCell
            let rawTasks = DataStore.shared.getRoutines(for: selectedDate)

            let sortedTasks = rawTasks.sorted { t1, t2 in
                let c1 = Calendar.current.dateComponents([.hour, .minute], from: t1.time)
                let c2 = Calendar.current.dateComponents([.hour, .minute], from: t2.time)

                let minutes1 = (c1.hour ?? 0) * 60 + (c1.minute ?? 0)
                let minutes2 = (c2.hour ?? 0) * 60 + (c2.minute ?? 0)

                if minutes1 != minutes2 {
                    return minutes1 < minutes2
                }

                // same time → incomplete first
                return t1.isCompleted == false && t2.isCompleted == true
            }

            cell.configureRoutineCell(tasks: sortedTasks, date: Date())

            return cell
        }
        
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "brainBoostersCardCollectionViewCell", for: indexPath) as! BrainBoostersCardCollectionViewCell
            let brainBoosters = brainBoosters[indexPath.row]
            cell.configureBrainBoostersCell(brainBooster: brainBoosters)
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: "header_cell", for: indexPath) as! HeaderView
        if indexPath.section == 0 {
            headerView.configureHeaderCell(text: "Memories", showChevron: false, isTappable: false)
        }
        else if indexPath.section == 1 {
            headerView.configureHeaderCell(text: "Memory Recap", showChevron: false, isTappable: false)
        }
        
        else if indexPath.section == 2 {
            headerView.configureHeaderCell(text: "My Routine",
                                           showChevron: true,
                                           isTappable: true,
                                           onTap: { [weak self] in
                                               self?.performSegue(withIdentifier: "showRoutine", sender: nil)
                                           }
            )
        }
        else {
            headerView.configureHeaderCell(text: "Brain Boosters", showChevron: false, isTappable: false)
        }
        return headerView
    }
    
}

extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            performSegue(withIdentifier: "showMemoryLane", sender: nil)
            return
        }
        if indexPath.section == 1 {
            performSegue(withIdentifier: "showMemoryRecap", sender: nil)
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

                print("Navigated to sudoku instructions screen")
            }
            else if segue.identifier == "showMatchThePairsInstructions",
                let _ = segue.destination as? MatchThePairsInstructionsViewController {

                print("Navigated to match the pairs instructions screen")
            }
            else if segue.identifier == "showCrosswordInstructions",
                let _ = segue.destination as? MatchThePairsInstructionsViewController {

                print("Navigated to crossword instructions screen")
            }
            return
        }

        if segue.identifier == "showMemoryRecap" {
            if let _ = segue.destination as? BaseViewController {
                print("Preparing Memory Recap (direct)")
            }
        }
        
        if segue.identifier == "showMemoryLane" {
            if let _ = segue.destination as? MemoryLaneHomeViewController {
                print("Preparing Memory Lane (direct)")
            }
        }
    }
}
