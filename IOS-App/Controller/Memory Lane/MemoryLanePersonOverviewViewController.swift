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
    let personOverview: [MemoryLanePersonInfo] = [
        MemoryLanePersonInfo(name: "Priyamani", summary: "Priyamani has been like family to you for years. Her warmth, understanding, and quiet support make every moment with her feel comforting and familiar.", hint: " ", personImage: "image_38"),
        
        MemoryLanePersonInfo(name: "Priyadarshan", summary: "Priyadarshan has been like family to you for years. You’ve shared many dinners, long conversations, and festival celebrations together. He always makes you laugh with his stories.", hint: " ", personImage: "image_39"),
        
        MemoryLanePersonInfo(name: "Priya", summary: "Priya feels more like family than a friend. Her energy, laughter, and easy conversations always brighten your day.", hint: " ", personImage: "image_42")
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
    
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        guard let nav = navigationController else { return }

        for vc in nav.viewControllers {
            if vc is HomeViewController {
                nav.popToViewController(vc, animated: false)
                return
            }
        }
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
