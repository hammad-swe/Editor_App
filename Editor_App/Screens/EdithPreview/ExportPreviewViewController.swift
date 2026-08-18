//
//  ExportPreviewViewController.swift
//  Editor_App
//
//  Created by Hammad Ali on 18/08/2026.
//

import UIKit
import AVFoundation
import Photos

class ExportPreviewViewController: UIViewController {
    
    @IBOutlet weak var playerContainerView: UIView!
    
    var exportedVideoURL: URL!
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Preview"
        setupPlayer()
        setupDownloadButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = playerContainerView.bounds
    }
    
    private func setupPlayer() {
        player = AVPlayer(url: exportedVideoURL)
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
    
    private func setupDownloadButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Download", style: .done, target: self, action: #selector(downloadTapped)
        )
    }
    
    @objc private func downloadTapped() {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if status == .authorized || status == .limited {
                    self.saveToPhotos()
                } else {
                    self.showAlert("Enable Photos access in Settings to save your video.")
                }
            }
        }
    }
    
    private func saveToPhotos() {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.center = view.center
        spinner.startAnimating()
        view.addSubview(spinner)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.exportedVideoURL)
        }) { [weak self] success, error in
            DispatchQueue.main.async {
                spinner.stopAnimating()
                spinner.removeFromSuperview()
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
                
                if success {
                    self?.showAlert("Video saved to your Photos library.")
                } else {
                    self?.showAlert("Couldn't save video: \(error?.localizedDescription ?? "unknown error")")
                }
            }
        }
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
