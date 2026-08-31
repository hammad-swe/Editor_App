//
//  AudioManagerViewController.swift
//  Editor_App
//
//  Created by Antigravity on 25/08/2026.
//

import UIKit
import AVFoundation
import UniformTypeIdentifiers
import PhotosUI

class AudioManagerViewController: UIViewController, EditorStepViewController {

    weak var stepDelegate: EditorStepDelegate?
    var viewModel: VideoEditingViewModel!
    var onComplete: (() -> Void)?

    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var muteSwitch: UISwitch!
    @IBOutlet weak var addAudioButton: UIButton!
    @IBOutlet weak var audioNameLabel: UILabel!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var audioPlayer: AVAudioPlayer?
    private var selectedAudioURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Audio Manager"
        setupUI()
        setupPlayer()
        restoreSelection()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
    }

    private func setupUI() {
        stepLabel?.text = "Step 3 of \(viewModel?.totalSteps ?? 6): Audio Manager"
        videoContainerView.layer.cornerRadius = 14
        videoContainerView.clipsToBounds = true
        videoContainerView.backgroundColor = .black

        addAudioButton.layer.cornerRadius = 10
        muteSwitch.onTintColor = .systemBlue

        backButton?.layer.cornerRadius = 10
        skipButton?.layer.cornerRadius = 10
        nextButton?.layer.cornerRadius = 10

        if let vm = viewModel {
            backButton?.isEnabled = !vm.isFirstStep
            backButton?.alpha = vm.isFirstStep ? 0.5 : 1.0
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

        player?.isMuted = viewModel?.model.muteOriginalAudio ?? false
        player?.play()
    }

    private func restoreSelection() {
        muteSwitch.isOn = viewModel?.model.muteOriginalAudio ?? false
        selectedAudioURL = viewModel?.model.replacementAudioURL
        volumeSlider.value = viewModel?.model.replacementAudioVolume ?? 1.0

        if let audioURL = selectedAudioURL {
            audioNameLabel.text = "🎵 " + audioURL.lastPathComponent
        } else {
            audioNameLabel.text = "No custom audio selected"
        }
    }

    @IBAction func muteSwitchChanged(_ sender: UISwitch) {
        player?.isMuted = sender.isOn
        viewModel?.setMuteOriginalAudio(sender.isOn)
    }

    @IBAction func addAudioTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add Audio", message: "Select audio source:", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Pick Audio File (.mp3, .m4a, .wav)", style: .default, handler: { [weak self] _ in
            self?.presentDocumentPicker()
        }))
        
        alert.addAction(UIAlertAction(title: "Extract Audio from Gallery Video", style: .default, handler: { [weak self] _ in
            self?.presentVideoPicker()
        }))
        
        if selectedAudioURL != nil {
            alert.addAction(UIAlertAction(title: "Remove Added Audio", style: .destructive, handler: { [weak self] _ in
                self?.selectedAudioURL = nil
                self?.audioNameLabel.text = "No custom audio selected"
                self?.viewModel?.setReplacementAudio(url: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func presentDocumentPicker() {
        let types: [UTType] = [.audio, .mp3, .mpeg4Audio, .wav]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func presentVideoPicker() {
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @IBAction func volumeChanged(_ sender: UISlider) {
        viewModel?.setReplacementAudio(url: selectedAudioURL, volume: sender.value)
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
        viewModel?.setMuteOriginalAudio(muteSwitch.isOn)
        viewModel?.setReplacementAudio(url: selectedAudioURL, volume: volumeSlider.value)
    }
}

// MARK: - UIDocumentPickerDelegate

extension AudioManagerViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        selectedAudioURL = url
        audioNameLabel.text = "🎵 " + url.lastPathComponent
        viewModel?.setReplacementAudio(url: url, volume: volumeSlider.value)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension AudioManagerViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider else { return }

        provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
            guard let url = url else { return }
            let tempCopy = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + "_" + url.lastPathComponent)
            try? FileManager.default.copyItem(at: url, to: tempCopy)
            DispatchQueue.main.async {
                self?.selectedAudioURL = tempCopy
                self?.audioNameLabel.text = "🎬 Audio Extracted: " + tempCopy.lastPathComponent
                self?.viewModel?.setReplacementAudio(url: tempCopy, volume: self?.volumeSlider.value ?? 1.0)
            }
        }
    }
}
