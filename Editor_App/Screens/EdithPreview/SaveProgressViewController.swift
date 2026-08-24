//
//  SaveProgressViewController.swift
//  Editor_App
//
//  Created by Antigravity on 21/08/2026.
//

import UIKit
import Photos

class SaveProgressViewController: UIViewController {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var savePhotosButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var actionStackView: UIStackView!
    
    var exportedVideoURL: URL!
    var headlineText: String?
    var thumbnailImage: UIImage?
    var coverImage: UIImage?

    private var progressShapeLayer: CAShapeLayer!
    private var trackShapeLayer: CAShapeLayer!
    private var displayLink: CADisplayLink?
    private var currentProgress: CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saving Project"
        navigationItem.hidesBackButton = true
        setupUI()
        extractThumbnail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupProgressRing()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSaveProcess()
    }

    private func setupUI() {
        thumbnailImageView.layer.cornerRadius = 12
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.backgroundColor = .black
        
        shareButton.layer.cornerRadius = 12
        savePhotosButton.layer.cornerRadius = 12
        doneButton.layer.cornerRadius = 12
        
        actionStackView.isHidden = true
        actionStackView.alpha = 0.0
        doneButton.isHidden = true
        doneButton.alpha = 0.0
        
        statusLabel.text = "Rendering & Saving Project..."
        percentageLabel.text = "0%"
    }
    
    private func extractThumbnail() {
        if let thumb = thumbnailImage {
            thumbnailImageView.image = thumb
            return
        }
        guard let url = exportedVideoURL else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            
            if let cgImage = try? generator.copyCGImage(at: .zero, actualTime: nil) {
                let img = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    self?.thumbnailImageView.image = img
                }
            }
        }
    }

    private func setupProgressRing() {
        guard progressShapeLayer == nil else { return }
        
        let center = CGPoint(x: progressContainerView.bounds.midX, y: progressContainerView.bounds.midY)
        let radius = min(progressContainerView.bounds.width, progressContainerView.bounds.height) / 2 - 12
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi

        let circularPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )

        // Background Track Layer
        trackShapeLayer = CAShapeLayer()
        trackShapeLayer.path = circularPath.cgPath
        trackShapeLayer.strokeColor = UIColor.systemGray5.cgColor
        trackShapeLayer.lineWidth = 10
        trackShapeLayer.fillColor = UIColor.clear.cgColor
        trackShapeLayer.lineCap = .round
        progressContainerView.layer.addSublayer(trackShapeLayer)

        // Animated Progress Layer
        progressShapeLayer = CAShapeLayer()
        progressShapeLayer.path = circularPath.cgPath
        progressShapeLayer.strokeColor = UIColor.systemBlue.cgColor
        progressShapeLayer.lineWidth = 10
        progressShapeLayer.fillColor = UIColor.clear.cgColor
        progressShapeLayer.lineCap = .round
        progressShapeLayer.strokeEnd = 0.0
        progressContainerView.layer.addSublayer(progressShapeLayer)
    }

    private func startSaveProcess() {
        // Run CoreData save in background
        CoreDataManager.shared.saveProject(
            exportedVideoURL: exportedVideoURL,
            headlineText: headlineText,
            coverImage: coverImage
        ) { [weak self] success in
            DispatchQueue.main.async {
                self?.animateProgressCompletion()
            }
        }
    }

    private func animateProgressCompletion() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgressAnimation))
        displayLink?.add(to: .main, forMode: .default)
    }

    @objc private func updateProgressAnimation() {
        currentProgress += 0.02
        if currentProgress >= 1.0 {
            currentProgress = 1.0
            displayLink?.invalidate()
            displayLink = nil
            onSaveCompleted()
        }
        
        progressShapeLayer.strokeEnd = currentProgress
        let percentage = Int(currentProgress * 100)
        percentageLabel.text = "\(percentage)%"
    }

    private func onSaveCompleted() {
        progressShapeLayer.strokeColor = UIColor.systemGreen.cgColor
        percentageLabel.text = "✓"
        percentageLabel.textColor = .systemGreen
        statusLabel.text = "Project Saved Successfully! 🎉"
        
        UIView.animate(withDuration: 0.4) {
            self.actionStackView.isHidden = false
            self.actionStackView.alpha = 1.0
            self.doneButton.isHidden = false
            self.doneButton.alpha = 1.0
        }
    }

    // MARK: - Actions

    @IBAction func shareTapped(_ sender: UIButton) {
        guard let videoURL = exportedVideoURL else { return }
        let activityVC = UIActivityViewController(activityItems: [videoURL], applicationActivities: nil)
        present(activityVC, animated: true)
    }

    @IBAction func savePhotosTapped(_ sender: UIButton) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if status == .authorized || status == .limited {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.exportedVideoURL)
                    }) { success, error in
                        DispatchQueue.main.async {
                            let msg = success ? "Saved to Photos!" : "Could not save to Photos."
                            let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                        }
                    }
                } else {
                    let alert = UIAlertController(title: "Permission Required", message: "Enable Photos access in Settings.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    @IBAction func doneTapped(_ sender: UIButton) {
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
}
