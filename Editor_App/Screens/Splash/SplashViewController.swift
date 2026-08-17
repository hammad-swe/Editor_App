//
//  SplashViewController.swift
//  Editor_App
//
//  Created by Hammad Ali on 17/08/2026.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        splashStarter()
        
    }

    private func splashStarter(){
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){ [weak self] in
                self?.goToLoginScreen()
            }
            
        }

        private func goToLoginScreen(){
            let vc = GetstartedViewController(nibName: "GetstartedViewController", bundle: nil)
          self.navigationController?.pushViewController(vc, animated: true)
        }
}
