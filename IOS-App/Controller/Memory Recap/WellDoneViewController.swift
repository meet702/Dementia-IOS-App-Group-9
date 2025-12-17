//
//  WellDoneViewController.swift
//  bgGradient2
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class WellDoneViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func goAgainTapped(_ sender: Any) {
        if let nav = self.navigationController {
            for vc in nav.viewControllers {
                if vc is BaseViewController {
                    nav.popToViewController(vc, animated: true)
                    return
                }
            }
        }
    }
    @IBAction func homeButtonTapped(_ sender: Any) {
        guard let nav = navigationController else { return }

        for vc in nav.viewControllers {
            if vc is HomeViewController {
                nav.popToViewController(vc, animated: false)
                return
            }
        }
    }
}
