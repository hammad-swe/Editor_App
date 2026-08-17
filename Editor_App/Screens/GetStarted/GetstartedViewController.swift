//
//  GetstartedViewController.swift
//  Editor_App
//
//  Created by Hammad Ali on 17/08/2026.
//

import UIKit

class GetstartedViewController: UIViewController {
    
    
    @IBOutlet weak var getbutton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        getbutton.layer.borderColor = UIColor.green.cgColor
        getbutton.layer.borderWidth = 1.0
        getbutton.layer.cornerRadius = 12
    }
    
    
    @IBAction func getButton(_ sender: UIButton) {
        
        let vc =  MainViewController(nibName: "MainViewController", bundle: nil)
      self.navigationController?.pushViewController(vc, animated: true)
    }
    

}
