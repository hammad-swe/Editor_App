//
//  SplashViewController.swift
//  Editor_App
//
//  Created by Hammad Ali on 17/08/2026.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var splashIcon: UIImageView!
    @IBOutlet weak var appTitleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    private let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupGradientBackground()
        setupInitialAnimation()
        splashStarter()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    private func setupGradientBackground() {
        gradientLayer.colors = [
            UIColor(red: 0.08, green: 0.12, blue: 0.28, alpha: 1.0).cgColor,
            UIColor(red: 0.02, green: 0.04, blue: 0.12, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupInitialAnimation() {
        splashIcon.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        splashIcon.alpha = 0.0
        if appTitleLabel != nil {
            appTitleLabel.alpha = 0.0
            appTitleLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        }
        if subtitleLabel != nil {
            subtitleLabel.alpha = 0.0
            subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        }

        UIView.animate(withDuration: 1.0, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.splashIcon.transform = .identity
            self.splashIcon.alpha = 1.0
        })

        UIView.animate(withDuration: 0.8, delay: 0.5, options: [.curveEaseOut], animations: {
            self.appTitleLabel?.alpha = 1.0
            self.appTitleLabel?.transform = .identity
            self.subtitleLabel?.alpha = 1.0
            self.subtitleLabel?.transform = .identity
        })
    }

    private func splashStarter() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.goToGetStartedScreen()
        }
    }

    private func goToGetStartedScreen() {
        let vc = GetstartedViewController(nibName: "GetstartedViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
}
