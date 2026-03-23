import UIKit

class OnboardingRoleSelectionViewController: UIViewController {

    @IBOutlet weak var rolesCollectionView: UICollectionView!

    private let roles: [RoleModel] = [
        RoleModel(title: "Patient", subtitle: "Relive memories. Stay sharp daily."),
        RoleModel(title: "Family", subtitle: "Support memories. Guide daily life.")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.99, green: 0.96, blue: 0.91, alpha: 1)
        setupCollectionView()
    }
    
    var verifiedPhone: String = ""  // ✅ passed from OTPVerificationVC

    private func setupCollectionView() {

        rolesCollectionView.backgroundColor = .clear

        rolesCollectionView.register(
            UINib(nibName: "RoleCardCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "roleCardCollectionViewCell"
        )

        rolesCollectionView.dataSource = self
        rolesCollectionView.delegate = self
        rolesCollectionView.collectionViewLayout = generateLayout()
    }

    private func generateLayout() -> UICollectionViewLayout {

        UICollectionViewCompositionalLayout { _, _ in

            let item = NSCollectionLayoutItem(
                layoutSize: .init(widthDimension: .fractionalWidth(1),
                                  heightDimension: .estimated(150))
            )

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: .init(widthDimension: .fractionalWidth(1),
                                  heightDimension: .estimated(120)),
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 24
            section.contentInsets = .init(top: 8, leading: 24, bottom: 24, trailing: 24)

            return section
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showPatientDetails",
           let dest = segue.destination as? PatientInputDetailsViewController {
            dest.navigationItem.title = "Patient"
            dest.verifiedPhone = verifiedPhone  // ✅
        }

        if segue.identifier == "showCaregiverDetails",
           let dest = segue.destination as? CaregiverInputDetailsViewController {
            dest.navigationItem.title = "Caregiver"
            dest.verifiedPhone = verifiedPhone  // ✅
        }
    }
}

extension OnboardingRoleSelectionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        roles.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "roleCardCollectionViewCell",
            for: indexPath
        ) as! RoleCardCollectionViewCell

        cell.configure(with: roles[indexPath.item])
        return cell
    }
}

extension OnboardingRoleSelectionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        let segueID = indexPath.item == 0
        ? "showPatientDetails"
        : "showCaregiverDetails"

        performSegue(withIdentifier: segueID, sender: nil)
    }
}
