import UIKit

class MemoryLaneHomeViewController: UIViewController {

    @IBOutlet weak var collageImageView: UIImageView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var newSessionButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        collageImageView.image = UIImage(named: "Group 139")
    }

    @IBAction func newSessionButtonTapped(_ sender: UIButton) {
        navigateToPictureIntro()
    }

    @IBAction func continueButtonTapped(_ sender: UIButton) {
        //navigateToLastPlayedStep()
    }

    

    private func navigateToPictureIntro() {
        let storyboard = UIStoryboard(name: "MemoryLane", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "MemoryLanePictureIntroVC")
        navigationController?.pushViewController(nextVC, animated: false)
    }



    
}


