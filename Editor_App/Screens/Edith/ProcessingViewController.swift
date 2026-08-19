//
//  ProcessingViewController.swift
//  Editor_App
//
//  Created by Antigravity on 19/08/2026.
//

import UIKit

class ProcessingViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var cardView: UIView!

    var viewModel: VideoEditingViewModel!
    var onComplete: ((URL?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Processing"
        navigationItem.hidesBackButton = true

        setupUI()
        startProcessing()
    }

    private func setupUI() {
        if cardView != nil {
            cardView.layer.cornerRadius = 16
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOpacity = 0.1
            cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
            cardView.layer.shadowRadius = 8
        }
        activityIndicator?.startAnimating()
    }

    private func startProcessing() {
        statusLabel?.text = "Processing Video..."
        detailLabel?.text = "Rendering overlays and exporting..."

        let previewBounds = CGRect(x: 0, y: 0, width: 393, height: 314)

        viewModel.processVideo(previewBounds: previewBounds) { [weak self] outputURL in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.onComplete?(outputURL)
            }
        }
    }
}
