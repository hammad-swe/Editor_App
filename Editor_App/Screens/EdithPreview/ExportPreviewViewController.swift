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
    @IBOutlet weak var saveProjectButton: UIButton!
    @IBOutlet weak var exportGalleryButton: UIButton!

    var exportedVideoURL: URL!
    var headlineText: String?

    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Preview"
        setupPlayer()
        setupNavButtons()
        setupButtonsUI()
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

    private func setupNavButtons() {
        let editButton = UIBarButtonItem(
            title: "Edit", style: .plain, target: self, action: #selector(editTapped)
        )
        navigationItem.leftBarButtonItem = editButton
    }

    private func setupButtonsUI() {
        if saveProjectButton != nil {
            saveProjectButton.layer.cornerRadius = 10
            saveProjectButton.backgroundColor = .systemBlue
        }
        if exportGalleryButton != nil {
            exportGalleryButton.layer.cornerRadius = 10
            exportGalleryButton.backgroundColor = .systemGreen
        }
    }

    @objc private func editTapped() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func saveProjectTapped(_ sender: UIButton) {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.center = view.center
        spinner.startAnimating()
        view.addSubview(spinner)

        CoreDataManager.shared.saveProject(
            exportedVideoURL: exportedVideoURL,
            headlineText: headlineText
        ) { [weak self] success in
            spinner.stopAnimating()
            spinner.removeFromSuperview()

            if success {
                self?.showAlert("Project saved successfully to local storage!")
            } else {
                self?.showAlert("Could not save project to local storage.")
            }
        }
    }

    @IBAction func exportGalleryTapped(_ sender: UIButton) {
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

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.exportedVideoURL)
        }) { [weak self] success, error in
            DispatchQueue.main.async {
                spinner.stopAnimating()
                spinner.removeFromSuperview()

                if success {
                    self?.showAlert("Video exported and saved to your Photos library!")
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
