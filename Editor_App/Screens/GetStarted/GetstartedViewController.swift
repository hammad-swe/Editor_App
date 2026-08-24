//
//  GetstartedViewController.swift
//  Editor_App
//
//  Created by Hammad Ali on 17/08/2026.
//

import UIKit

class GetstartedViewController: UIViewController {
    
    @IBOutlet weak var getbutton: UIButton!
    @IBOutlet weak var heroCardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        if heroCardView != nil {
            heroCardView.layer.cornerRadius = 20
            heroCardView.clipsToBounds = true
            heroCardView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        }
        
        getbutton.layer.cornerRadius = 14
        getbutton.backgroundColor = .systemBlue
        getbutton.setTitle("Get Started", for: .normal)
        getbutton.setTitleColor(.white, for: .normal)
        getbutton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        getbutton.layer.borderWidth = 0
    }
    
    @IBAction func getButton(_ sender: UIButton) {
        let vc = MainViewController(nibName: "MainViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
}
