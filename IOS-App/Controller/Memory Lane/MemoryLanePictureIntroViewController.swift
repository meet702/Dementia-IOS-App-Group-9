//
//  MemoryLanePictureIntroViewController.swift
//  IOS-App
//
//  Created by SDC-User on 25/11/25.
//

import UIKit

class MemoryLanePictureIntroViewController: UIViewController {

    @IBOutlet weak var mainImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mainImageView.image = UIImage(named: "image_40")
    }

    @IBAction func screenTapped(_ sender: UIButton) {

      
        _ = mainImageView.image ?? UIImage()

     
        let peopleInPicture = ["Priyadarshan", "Priyamani", "Priya"]

      
        MemorySessionManager.shared.startImageSession(
            image: "image_40",
            peopleShown: peopleInPicture
        )

        print("Started image session for people:", peopleInPicture)

        
        goToNextScreen()
    }

    private func goToNextScreen() {
        let story = UIStoryboard(name: "MemoryLane", bundle: nil)
        let nextVC = story.instantiateViewController(
            withIdentifier: "MemoryLaneIdentifyPersonVC"
        )

        navigationController?.pushViewController(nextVC, animated: false)
    }
}
