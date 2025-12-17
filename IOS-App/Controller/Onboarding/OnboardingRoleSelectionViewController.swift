//
//  OnboardingRoleSelectionViewController.swift
//  onboardingScreen
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class OnboardingRoleSelectionViewController: UIViewController {

    @IBOutlet weak var rolesCollectionView: UICollectionView!

    private let roles: [RoleModel] = [
            RoleModel(
                title: "Patient",
                subtitle: "Relive happy memories, play simple mind games, and stay on track with daily routines."
            ),
            RoleModel(
                title: "Caregiver",
                subtitle: "Upload photos, view responses, and help your loved one stay engaged through memories, games, and daily reminders."
            )
        ]

        enum RoleType {
            case patient
            case caregiver
        }

        private var selectedRole: RoleType?

        override func viewDidLoad() {
            super.viewDidLoad()

            view.backgroundColor = UIColor(
                red: 0.99, green: 0.96, blue: 0.91, alpha: 1.0
            )

            setupCollectionView()
        }

        private func setupCollectionView() {
            rolesCollectionView.backgroundColor = .clear

            rolesCollectionView.register(
                UINib(nibName: "RoleCardCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "roleCardCollectionViewCell"
            )

            rolesCollectionView.dataSource = self
            rolesCollectionView.delegate   = self

            let layout = generateLayout()
            rolesCollectionView.setCollectionViewLayout(layout, animated: false)
        }

        private func generateLayout() -> UICollectionViewLayout {
            return UICollectionViewCompositionalLayout { sectionIndex, env in

                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(150)
                )
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 24
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 8,
                    leading: 24,
                    bottom: 24,
                    trailing: 24
                )

                return section
            }
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showPatientDetails" {
                if let dest = segue.destination as? PatientInputDetailsViewController {
                    dest.navigationItem.title = "Patient"
                }
            } else if segue.identifier == "showCaregiverDetails" {
                if let dest = segue.destination as? CaregiverInputDetailsViewController {
                    dest.navigationItem.title = "Caregiver"
                }
            }
        }
    }

extension OnboardingRoleSelectionViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return roles.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "roleCardCollectionViewCell",
            for: indexPath
        ) as! RoleCardCollectionViewCell

        let model = roles[indexPath.item]
        cell.configure(with: model)
        return cell
    }
}

extension OnboardingRoleSelectionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        if indexPath.item == 0 {
            selectedRole = .patient
            performSegue(withIdentifier: "showPatientDetails", sender: nil)
        } else {
            selectedRole = .caregiver
            performSegue(withIdentifier: "showCaregiverDetails", sender: nil)
        }
    }
}
