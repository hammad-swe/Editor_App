//
//  EditingViewController.swift
//  Editor_App
//
//  Created by Hammad Ali on 18/08/2026.
//

import UIKit
import AVFoundation

class EditingViewController: UIViewController {
    
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var headlineLabel: UILabel!
    
    var videoURL: URL!
    private var player: AVPlayer!
        private var playerLayer: AVPlayerLayer!
        
        var watermarkIcon: UIImage = UIImage(named: "shapes1")!
        var headlineText: String = "Wellcome to New Video"
    
    override func viewDidLoad() {
        super.viewDidLoad()
               title = "Edit"
        setupPlayer()
                setupOverlays()
                setupExportButton()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = playerContainerView.bounds
    }
    
    private func setupPlayer() {
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerContainerView.bounds
        playerLayer.videoGravity = .resizeAspect
        playerContainerView.layer.insertSublayer(playerLayer, at: 0)
        player.play()
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(loopVideo),
            name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem
        )
    }
    
    @objc private func loopVideo() {
        player.seek(to: .zero)
        player.play()
    }
    
    private func setupOverlays() {
        iconImageView.image = watermarkIcon
        iconImageView.tintColor = .white
        iconImageView.isUserInteractionEnabled = true
        addDragGesture(to: iconImageView)
        
        headlineLabel.text = headlineText
        headlineLabel.sizeToFit()
        startMarquee()
    }
    
    private func addDragGesture(to viewToDrag: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        viewToDrag.addGestureRecognizer(pan)
    }
    
    @objc private func handleDrag(_ gesture: UIPanGestureRecognizer) {
        guard let draggedView = gesture.view else { return }
        let translation = gesture.translation(in: view)
        draggedView.center = CGPoint(x: draggedView.center.x + translation.x, y: draggedView.center.y + translation.y)
        gesture.setTranslation(.zero, in: view)
    }
    
    private func startMarquee() {
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = view.bounds.width + headlineLabel.bounds.width / 2
        animation.toValue = -headlineLabel.bounds.width / 2
        animation.duration = 6.0
        animation.repeatCount = .infinity
        headlineLabel.layer.add(animation, forKey: "marquee")
    }
    
    private func setupExportButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Export", style: .done, target: self, action: #selector(exportTapped))
    }
    
    @objc private func exportTapped() {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.center = view.center
        spinner.startAnimating()
        view.addSubview(spinner)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        VideoExporter.shared.export(
            videoURL: videoURL,
            icon: watermarkIcon,
            iconFrame: iconImageView.frame,
            headlineText: headlineText,
            headlineFont: headlineLabel.font,
            previewBounds: playerContainerView.bounds
        ) { [weak self] outputURL in
            spinner.stopAnimating()
            spinner.removeFromSuperview()
            self?.navigationItem.rightBarButtonItem?.isEnabled = true
            
            guard let outputURL = outputURL else {
                self?.showAlert("Export failed. Try again.")
                return
            }
            
            let previewVC = ExportPreviewViewController(nibName: "ExportPreviewViewController", bundle: nil)
            previewVC.exportedVideoURL = outputURL
            self?.navigationController?.pushViewController(previewVC, animated: true)
        }
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

