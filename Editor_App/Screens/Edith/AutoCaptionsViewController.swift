//
//  AutoCaptionsViewController.swift
//  Editor_App
//
//  Created by Antigravity on 25/08/2026.
//

import UIKit
import AVFoundation

class AutoCaptionsViewController: UIViewController, EditorStepViewController {

    weak var stepDelegate: EditorStepDelegate?
    var viewModel: VideoEditingViewModel!

    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var subtitleContainerView: UIView!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var autoCaptionButton: UIButton!
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var styleButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserver: Any?
    private var playerEndObserver: Any?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Auto Captions"
        setupUI()
        setupPlayer()
        restoreExistingCaptions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
        viewModel?.applyModelTransforms(to: playerLayer)
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
        stepLabel.text = "Step 2 of \(viewModel?.totalSteps ?? 6): Auto Captions & Translation"
        videoContainerView.layer.cornerRadius = 16
        videoContainerView.clipsToBounds = true
        videoContainerView.backgroundColor = .black

        subtitleContainerView.layer.cornerRadius = 8
        subtitleContainerView.clipsToBounds = true
        subtitleContainerView.backgroundColor = viewModel?.model.captionStyle.backgroundColor ?? UIColor.black.withAlphaComponent(0.8)
        subtitleLabel.textColor = viewModel?.model.captionStyle.textColor ?? .white
        subtitleLabel.text = "Tap 'Auto Caption' to generate subtitles"

        autoCaptionButton.layer.cornerRadius = 10
        languageButton.layer.cornerRadius = 10
        styleButton.layer.cornerRadius = 10

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
            videoContainerView.layer.insertSublayer(pLayer, at: 0)
        }

        // Add periodic time observer to sync subtitles live with video playback
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.updateSubtitleForTime(time)
        }

        playerEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }

        player?.play()
    }

    private func updateSubtitleForTime(_ time: CMTime) {
        guard let vm = viewModel, vm.model.isCaptionsEnabled, !vm.model.captions.isEmpty else {
            return
        }

        let seconds = CMTimeGetSeconds(time)
        let activeSegment = vm.model.captions.first { seg in
            return seconds >= seg.startTime && seconds <= (seg.startTime + seg.duration)
        }

        if let seg = activeSegment {
            subtitleLabel.text = seg.text
            subtitleContainerView.isHidden = false
        } else {
            subtitleContainerView.isHidden = true
        }
    }

    private func restoreExistingCaptions() {
        if let vm = viewModel, vm.model.isCaptionsEnabled, !vm.model.captions.isEmpty {
            subtitleContainerView.isHidden = false
            languageButton.setTitle("🌐 \(vm.model.captionLanguage)", for: .normal)
            updateCaptionStyleUI(vm.model.captionStyle)
        }
    }

    private func updateCaptionStyleUI(_ style: CaptionStyle) {
        subtitleContainerView.backgroundColor = style.backgroundColor
        subtitleLabel.textColor = style.textColor
    }

    // MARK: - Actions

    @IBAction func autoCaptionTapped(_ sender: UIButton) {
        activityIndicator?.startAnimating()
        autoCaptionButton.isEnabled = false
        subtitleLabel.text = "Extracting speech from video audio..."
        subtitleContainerView.isHidden = false

        viewModel?.generateAutoCaptions { [weak self] segments in
            guard let self = self else { return }
            self.activityIndicator?.stopAnimating()
            self.autoCaptionButton.isEnabled = true

            if segments.isEmpty {
                self.subtitleLabel.text = "No speech detected in video"
            } else {
                self.subtitleLabel.text = segments.first?.text ?? ""
                self.player?.seek(to: .zero)
                self.player?.play()
            }
        }
    }

    @IBAction func languageTapped(_ sender: UIButton) {
        guard let vm = viewModel, !vm.model.captions.isEmpty else {
            let alert = UIAlertController(title: "Generate Captions First", message: "Tap 'Auto Caption' before translating language.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let alert = UIAlertController(title: "Select Target Language", message: "Audio will be translated into selected language:", preferredStyle: .actionSheet)

        for lang in CaptionTranslationService.supportedLanguages {
            alert.addAction(UIAlertAction(title: lang, style: .default, handler: { [weak self] _ in
                self?.viewModel?.translateCaptions(to: lang)
                self?.languageButton.setTitle("🌐 \(lang)", for: .normal)
                self?.subtitleLabel.text = self?.viewModel?.model.captions.first?.text ?? ""
                self?.player?.seek(to: .zero)
                self?.player?.play()
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @IBAction func styleTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Subtitle Style", message: "Choose caption background style:", preferredStyle: .actionSheet)

        for style in CaptionStyle.allCases {
            alert.addAction(UIAlertAction(title: style.rawValue, style: .default, handler: { [weak self] _ in
                self?.viewModel?.setCaptionStyle(style)
                self?.updateCaptionStyleUI(style)
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
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
        // Captions already stored in viewModel
    }

    deinit {
        if let obs = timeObserver {
            player?.removeTimeObserver(obs)
        }
        if let endObs = playerEndObserver {
            NotificationCenter.default.removeObserver(endObs)
        }
        player?.pause()
    }
}
