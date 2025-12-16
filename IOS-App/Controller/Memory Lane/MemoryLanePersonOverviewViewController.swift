//
//  MemoryLanePersonOverviewViewController.swift
//  MemoryLane
//
//  Created by SDC-User on 11/12/25.
//

import UIKit

class MemoryLanePersonOverviewViewController: UIViewController {

    @IBOutlet weak var memoryLaneCollectionView: UICollectionView!
    
    @IBOutlet weak var finishButton: UIButton!
    let personOverview: [MemoryLanePersonOverviewModel] = [
        MemoryLanePersonOverviewModel(name: "Priyamani", summary: "Priyadarshan has been like family to you for years. You’ve shared many dinners, long conversations, and festival celebrations together. He always makes you laugh with his stories.", personImage: "image 38"),
        MemoryLanePersonOverviewModel(name: "Priyadarshan", summary: "Priyadarshan has been like family to you for years. You’ve shared many dinners, long conversations, and festival celebrations together. He always makes you laugh with his stories.", personImage: "image 39"),
        MemoryLanePersonOverviewModel(name: "Priya", summary: "Priyadarshan has been like family to you for years. You’ve shared many dinners, long conversations, and festival celebrations together. He always makes you laugh with his stories.", personImage: "image 42")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        // Do any additional setup after loading the view.
        memoryLaneCollectionView.dataSource = self
        let layout = generateLayout()
        memoryLaneCollectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { section, environment in
            
            // Cell item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(260)   
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            // Group (vertical stack of 1 item)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(260)
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )

            // Section settings
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.interGroupSpacing = 20
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(
                top: 20,
                leading: 16,
                bottom: 20,
                trailing: 16
            )

            return sectionLayout
        }
    }

    
    func registerCell() {
        memoryLaneCollectionView.register(UINib(nibName: "MemoryLanePersonOverviewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "memoryLanePersonOverviewCollectionViewCell")
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: false)
    }
    
}

extension MemoryLanePersonOverviewViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return personOverview.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memoryLanePersonOverviewCollectionViewCell", for: indexPath) as! MemoryLanePersonOverviewCollectionViewCell
        let person = personOverview[indexPath.row]
        cell.configurePersonOverview(person: person)
        return cell
    }
    
    
}
