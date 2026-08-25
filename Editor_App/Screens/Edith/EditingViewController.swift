//
//  EditingViewController.swift
//  Editor_App
//
//  Created by Hammad Ali on 18/08/2026.
//

import UIKit

/// Coordinator container for multi-step video editing wizard
class EditingViewController: UIViewController {
    
    var videoURL: URL!
    var viewModel: VideoEditingViewModel!
    
    private var currentStepVC: UIViewController?
    private let containerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Edit Video"
        
        if viewModel == nil {
            guard let videoURL = videoURL else {
                fatalError("videoURL or viewModel must be provided")
            }
            viewModel = VideoEditingViewModel(videoURL: videoURL)
        }
        
        setupContainerView()
        setupNavigationBar()
        showStep(index: viewModel.currentStepIndex)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupNavigationBar() {
        let audioBtn = UIBarButtonItem(
            title: "🎵 Audio",
            style: .plain,
            target: self,
            action: #selector(audioManagerTapped)
        )
        navigationItem.rightBarButtonItem = audioBtn
    }

    @objc private func audioManagerTapped() {
        let audioVC = AudioManagerViewController(nibName: "AudioManagerViewController", bundle: nil)
        audioVC.viewModel = viewModel
        present(audioVC, animated: true)
    }
    
    private func setupContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func showStep(index: Int) {
        // Remove current step VC
        if let current = currentStepVC {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }
        
        let newStepVC: EditorStepViewController
        switch index {
        case 0:
            let cutVC = VideoCutSplitViewController(nibName: "VideoCutSplitViewController", bundle: nil)
            cutVC.viewModel = viewModel
            newStepVC = cutVC
        case 1:
            let cropVC = CropRotateViewController(nibName: "CropRotateViewController", bundle: nil)
            cropVC.viewModel = viewModel
            newStepVC = cropVC
        case 2:
            let frameVC = FrameTemplatesViewController(nibName: "FrameTemplatesViewController", bundle: nil)
            frameVC.viewModel = viewModel
            newStepVC = frameVC
        case 3:
            let logoVC = AddLogoStepViewController(nibName: "AddLogoStepViewController", bundle: nil)
            logoVC.viewModel = viewModel
            newStepVC = logoVC
        case 4:
            let textVC = AddTextStepViewController(nibName: "AddTextStepViewController", bundle: nil)
            textVC.viewModel = viewModel
            newStepVC = textVC
        default:
            return
        }
        
        newStepVC.stepDelegate = self
        addChild(newStepVC)
        newStepVC.view.frame = containerView.bounds
        newStepVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(newStepVC.view)
        newStepVC.didMove(toParent: self)
        
        currentStepVC = newStepVC
    }
    
    private func processAndPreviewVideo() {
        let processingVC = ProcessingViewController(nibName: "ProcessingViewController", bundle: nil)
        processingVC.viewModel = viewModel
        processingVC.onComplete = { [weak self] outputURL in
            guard let self = self else { return }
            
            guard let outputURL = outputURL else {
                self.navigationController?.popViewController(animated: true)
                let alert = UIAlertController(title: "Export Failed", message: "Could not process video. Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                return
            }
            
            let previewVC = ExportPreviewViewController(nibName: "ExportPreviewViewController", bundle: nil)
            previewVC.exportedVideoURL = outputURL
            previewVC.headlineText = self.viewModel.model.headlineText
            previewVC.coverImage = self.viewModel.model.coverImage
            
            var viewControllers = self.navigationController?.viewControllers ?? []
            if let index = viewControllers.firstIndex(of: processingVC) {
                viewControllers[index] = previewVC
                self.navigationController?.setViewControllers(viewControllers, animated: true)
            } else {
                self.navigationController?.pushViewController(previewVC, animated: true)
            }
        }
        
        navigationController?.pushViewController(processingVC, animated: true)
    }
}

// MARK: - EditorStepDelegate

extension EditingViewController: EditorStepDelegate {
    
    func stepDidTapNext(_ step: UIViewController) {
        if viewModel.isLastStep {
            processAndPreviewVideo()
        } else {
            _ = viewModel.nextStep()
            showStep(index: viewModel.currentStepIndex)
        }
    }
    
    func stepDidTapSkip(_ step: UIViewController) {
        if viewModel.isLastStep {
            processAndPreviewVideo()
        } else {
            _ = viewModel.nextStep()
            showStep(index: viewModel.currentStepIndex)
        }
    }
    
    func stepDidTapBack(_ step: UIViewController) {
        if viewModel.isFirstStep {
            navigationController?.popViewController(animated: true)
        } else {
            _ = viewModel.previousStep()
            showStep(index: viewModel.currentStepIndex)
        }
    }
}
