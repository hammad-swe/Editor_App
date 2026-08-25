//
//  CropRotateViewController.swift
//  Editor_App
//
//  Created by Antigravity on 25/08/2026.
//

import UIKit
import AVFoundation

class CropRotateViewController: UIViewController, EditorStepViewController {

    weak var stepDelegate: EditorStepDelegate?
    var viewModel: VideoEditingViewModel!

    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var rotateButton: UIButton!
    @IBOutlet weak var aspectRatioSegmentedControl: UISegmentedControl!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerObserver: Any?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Crop & Rotate Video"
        setupUI()
        setupPlayer()
        setupAspectRatioControl()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContainerAspectRatio(viewModel?.model.aspectRatio ?? .original)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player?.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }

    private func setupUI() {
        stepLabel.text = "Step 2 of \(viewModel?.totalSteps ?? 5): Crop, Rotate & Aspect Ratio"
        videoContainerView.layer.cornerRadius = 16
        videoContainerView.clipsToBounds = true
        videoContainerView.backgroundColor = .black

        cropButton.layer.cornerRadius = 10
        rotateButton.layer.cornerRadius = 10

        backButton.layer.cornerRadius = 10
        skipButton.layer.cornerRadius = 10
        nextButton.layer.cornerRadius = 10

        if let vm = viewModel {
            backButton.isEnabled = !vm.isFirstStep
            backButton.alpha = vm.isFirstStep ? 0.5 : 1.0
        }
    }

    private func setupPlayer() {
        guard let videoURL = viewModel?.model.videoURL else { return }
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = videoContainerView.bounds
        playerLayer?.videoGravity = .resizeAspect
        if let pLayer = playerLayer {
            videoContainerView.layer.addSublayer(pLayer)
        }

        playerObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }

        player?.play()
    }

    private func setupAspectRatioControl() {
        aspectRatioSegmentedControl.removeAllSegments()
        for (index, ratio) in VideoAspectRatio.allCases.enumerated() {
            aspectRatioSegmentedControl.insertSegment(withTitle: ratio.rawValue, at: index, animated: false)
        }
        
        let currentRatio = viewModel?.model.aspectRatio ?? .original
        if let aspectIndex = VideoAspectRatio.allCases.firstIndex(of: currentRatio) {
            aspectRatioSegmentedControl.selectedSegmentIndex = aspectIndex
        } else {
            aspectRatioSegmentedControl.selectedSegmentIndex = 0
        }

        aspectRatioSegmentedControl.selectedSegmentTintColor = .systemBlue
        let normalTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: 11, weight: .medium)]
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 11, weight: .bold)]
        aspectRatioSegmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        aspectRatioSegmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)

        aspectRatioSegmentedControl.addTarget(self, action: #selector(aspectRatioChanged(_:)), for: .valueChanged)
    }

    @objc private func aspectRatioChanged(_ sender: UISegmentedControl) {
        let allRatios = VideoAspectRatio.allCases
        guard sender.selectedSegmentIndex < allRatios.count else { return }
        let selectedRatio = allRatios[sender.selectedSegmentIndex]
        viewModel?.setAspectRatio(selectedRatio)
        updateContainerAspectRatio(selectedRatio)
        
        player?.seek(to: .zero)
        player?.play()
    }

    private func updateContainerAspectRatio(_ ratio: VideoAspectRatio) {
        let containerW = videoContainerView.bounds.width > 0 ? videoContainerView.bounds.width : (view.bounds.width - 32.0)
        let containerH: CGFloat = 300.0

        let targetRect: CGRect
        if let targetRatio = ratio.ratioValue {
            let containerAspect = containerW / containerH
            var innerW: CGFloat = containerW
            var innerH: CGFloat = containerH

            if containerAspect > targetRatio {
                innerH = containerH
                innerW = containerH * targetRatio
            } else {
                innerW = containerW
                innerH = containerW / targetRatio
            }

            let originX = (containerW - innerW) / 2.0
            let originY = (containerH - innerH) / 2.0
            targetRect = CGRect(x: originX, y: originY, width: innerW, height: innerH)
        } else {
            targetRect = CGRect(x: 0, y: 0, width: containerW, height: containerH)
        }

        UIView.animate(withDuration: 0.3) {
            self.playerLayer?.frame = targetRect
            self.playerLayer?.videoGravity = .resizeAspect
        }
    }

    @IBAction func cropTapped(_ sender: UIButton) {
        let cropOverlay = CropOverlayView(frame: videoContainerView.bounds)
        cropOverlay.delegate = self
        videoContainerView.addSubview(cropOverlay)
    }

    @IBAction func rotateTapped(_ sender: UIButton) {
        viewModel.rotateVideoClockwise()
        let degrees = viewModel.model.rotationDegrees
        let radians = CGFloat(degrees) * .pi / 180.0
        UIView.animate(withDuration: 0.3) {
            self.playerLayer?.transform = CATransform3DMakeRotation(radians, 0, 0, 1)
        }
    }

    // MARK: - EditorStepViewController Protocol

    @IBAction func backTapped(_ sender: UIButton) {
        stepDelegate?.stepDidTapBack(self)
    }

    @IBAction func skipTapped(_ sender: UIButton) {
        stepDelegate?.stepDidTapSkip(self)
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        applyToViewModel()
        stepDelegate?.stepDidTapNext(self)
    }

    func applyToViewModel() {
        let selectedIndex = aspectRatioSegmentedControl.selectedSegmentIndex
        if selectedIndex >= 0 && selectedIndex < VideoAspectRatio.allCases.count {
            let selectedRatio = VideoAspectRatio.allCases[selectedIndex]
            viewModel?.setAspectRatio(selectedRatio)
        }
    }

    deinit {
        if let obs = playerObserver {
            NotificationCenter.default.removeObserver(obs)
        }
        player?.pause()
    }
}

// MARK: - CropOverlayDelegate

extension CropRotateViewController: CropOverlayDelegate {
    func cropOverlayDidFinish(normalizedCropRect: CGRect) {
        viewModel?.setCropRect(normalizedCropRect)
        playerLayer?.contentsRect = normalizedCropRect
        player?.seek(to: .zero)
        player?.play()
    }

    func cropOverlayDidCancel() {
        // Overlay cancelled
    }
}
