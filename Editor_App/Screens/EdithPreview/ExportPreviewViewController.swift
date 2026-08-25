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
    private let shareButton = UIButton(type: .system)
    private let infoBadgeStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Export Preview"
        setupPlayer()
        setupNavButtons()
        setupButtonsUI()
        setupInfoBadges()
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
        playerContainerView.layer.cornerRadius = 18
        playerContainerView.layer.masksToBounds = true
        playerContainerView.backgroundColor = .black
        
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

    private func setupInfoBadges() {
        let tag1 = createBadgeLabel(text: "🎬 HD 1080p", color: .systemBlue)
        let tag2 = createBadgeLabel(text: "⚡ Ready to Share", color: .systemPurple)
        
        infoBadgeStack.axis = .horizontal
        infoBadgeStack.spacing = 8
        infoBadgeStack.alignment = .center
        infoBadgeStack.distribution = .equalSpacing
        infoBadgeStack.translatesAutoresizingMaskIntoConstraints = false
        
        infoBadgeStack.addArrangedSubview(tag1)
        infoBadgeStack.addArrangedSubview(tag2)
        
        view.addSubview(infoBadgeStack)
        
        NSLayoutConstraint.activate([
            infoBadgeStack.topAnchor.constraint(equalTo: playerContainerView.bottomAnchor, constant: 12),
            infoBadgeStack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func createBadgeLabel(text: String, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = "  \(text)  "
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = color
        label.backgroundColor = color.withAlphaComponent(0.12)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }

    private func setupButtonsUI() {
        if saveProjectButton != nil {
            saveProjectButton.layer.cornerRadius = 14
            saveProjectButton.backgroundColor = .systemBlue
            saveProjectButton.setTitle(" Save Project", for: .normal)
            saveProjectButton.setImage(UIImage(systemName: "folder.badge.plus"), for: .normal)
            saveProjectButton.tintColor = .white
            saveProjectButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        }
        if exportGalleryButton != nil {
            exportGalleryButton.layer.cornerRadius = 14
            exportGalleryButton.backgroundColor = .systemGreen
            exportGalleryButton.setTitle(" Export to Photos", for: .normal)
            exportGalleryButton.setImage(UIImage(systemName: "arrow.down.to.line.square"), for: .normal)
            exportGalleryButton.tintColor = .white
            exportGalleryButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
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
