//
//  VideoCutSplitViewController.swift
//  Editor_App
//
//  Created by Antigravity on 25/08/2026.
//

import UIKit
import AVFoundation

class VideoCutSplitViewController: UIViewController, EditorStepViewController {

    weak var stepDelegate: EditorStepDelegate?
    var viewModel: VideoEditingViewModel!

    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var timeRangeLabel: UILabel!
    @IBOutlet weak var startTimeSlider: UISlider!
    @IBOutlet weak var endTimeSlider: UISlider!
    @IBOutlet weak var splitButton: UIButton!
    @IBOutlet weak var cutButton: UIButton!
    @IBOutlet weak var previewTrimButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var videoDuration: CMTime = .zero
    private var playerObserver: Any?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cut & Split Video"
        setupUI()
        setupPlayer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
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
        stepLabel.text = "Step 1 of \(viewModel?.totalSteps ?? 5): Cut & Split Video"
        videoContainerView.layer.cornerRadius = 16
        videoContainerView.clipsToBounds = true
        videoContainerView.backgroundColor = .black

        splitButton.layer.cornerRadius = 10
        cutButton.layer.cornerRadius = 10
        previewTrimButton.layer.cornerRadius = 10

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
        let asset = AVURLAsset(url: videoURL)
        videoDuration = asset.duration

        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = videoContainerView.bounds
        playerLayer?.videoGravity = .resizeAspect
        if let pLayer = playerLayer {
            videoContainerView.layer.addSublayer(pLayer)
        }

        let totalSeconds = Float(CMTimeGetSeconds(videoDuration))
        startTimeSlider.minimumValue = 0
        startTimeSlider.maximumValue = totalSeconds
        startTimeSlider.value = 0

        endTimeSlider.minimumValue = 0
        endTimeSlider.maximumValue = totalSeconds
        endTimeSlider.value = totalSeconds

        updateTimeRangeLabel()

        playerObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.player?.seek(to: CMTime(seconds: Double(self?.startTimeSlider.value ?? 0), preferredTimescale: 600))
            self?.player?.play()
        }

        player?.play()
    }

    private func updateTimeRangeLabel() {
        let startSec = Int(startTimeSlider.value)
        let endSec = Int(endTimeSlider.value)
        let startMin = startSec / 60
        let startS = startSec % 60
        let endMin = endSec / 60
        let endS = endSec % 60

        timeRangeLabel.text = String(format: "Trim Range: %02d:%02d — %02d:%02d", startMin, startS, endMin, endS)
    }

    @IBAction func startTimeChanged(_ sender: UISlider) {
        if sender.value >= endTimeSlider.value - 0.5 {
            sender.value = endTimeSlider.value - 0.5
        }
        updateTimeRangeLabel()
        player?.seek(to: CMTime(seconds: Double(sender.value), preferredTimescale: 600))
    }

    @IBAction func endTimeChanged(_ sender: UISlider) {
        if sender.value <= startTimeSlider.value + 0.5 {
            sender.value = startTimeSlider.value + 0.5
        }
        updateTimeRangeLabel()
        player?.seek(to: CMTime(seconds: Double(sender.value), preferredTimescale: 600))
    }

    @IBAction func splitTapped(_ sender: UIButton) {
        guard let currentCMTime = player?.currentTime() else { return }
        let currentSec = CMTimeGetSeconds(currentCMTime)
        
        let alert = UIAlertController(
            title: "Split Video",
            message: String(format: "Split video at %02d:%02d?", Int(currentSec) / 60, Int(currentSec) % 60),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Keep First Half", style: .default, handler: { [weak self] _ in
            self?.endTimeSlider.value = Float(currentSec)
            self?.updateTimeRangeLabel()
        }))
        alert.addAction(UIAlertAction(title: "Keep Second Half", style: .default, handler: { [weak self] _ in
            self?.startTimeSlider.value = Float(currentSec)
            self?.updateTimeRangeLabel()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @IBAction func cutTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Cut Selection",
            message: "Cut out current selection and reset trim range?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            self.startTimeSlider.value = 0
            self.endTimeSlider.value = Float(CMTimeGetSeconds(self.videoDuration))
            self.updateTimeRangeLabel()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @IBAction func previewTrimTapped(_ sender: UIButton) {
        let startCM = CMTime(seconds: Double(startTimeSlider.value), preferredTimescale: 600)
        player?.seek(to: startCM)
        player?.play()
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
        let startCM = CMTime(seconds: Double(startTimeSlider.value), preferredTimescale: 600)
        let endCM = CMTime(seconds: Double(endTimeSlider.value), preferredTimescale: 600)
        viewModel?.setTrimRange(start: startCM, end: endCM)
    }

    deinit {
        if let obs = playerObserver {
            NotificationCenter.default.removeObserver(obs)
        }
        player?.pause()
    }
}
