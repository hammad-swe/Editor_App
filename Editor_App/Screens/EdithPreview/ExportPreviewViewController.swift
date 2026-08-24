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
    var coverImage: UIImage?

    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Preview"
        setupPlayer()
        setupNavButtons()
        setupButtonsUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
        
        let doneButton = UIBarButtonItem(
            title: "Done", style: .done, target: self, action: #selector(doneTapped)
        )
        navigationItem.rightBarButtonItem = doneButton
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
    
    @objc private func doneTapped() {
        navigateToDashboard()
    }

    @IBAction func saveProjectTapped(_ sender: UIButton) {
        let saveProgressVC = SaveProgressViewController(nibName: "SaveProgressViewController", bundle: nil)
        saveProgressVC.exportedVideoURL = exportedVideoURL
        saveProgressVC.headlineText = headlineText
        saveProgressVC.coverImage = coverImage
        navigationController?.pushViewController(saveProgressVC, animated: true)
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
                    self?.showAlertAndNavigateToDashboard("Video exported and saved to your Photos library!")
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

    private func showAlertAndNavigateToDashboard(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigateToDashboard()
        })
        present(alert, animated: true)
    }

    private func navigateToDashboard() {
        if let viewControllers = navigationController?.viewControllers {
            for vc in viewControllers {
                if vc is MainViewController {
                    navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        }
        navigationController?.popToRootViewController(animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
