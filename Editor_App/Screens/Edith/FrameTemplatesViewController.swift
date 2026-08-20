//
//  FrameTemplatesViewController.swift
//  Editor_App
//
//  Created by Antigravity on 20/08/2026.
//

import UIKit
import AVFoundation

class FrameTemplatesViewController: UIViewController, EditorStepViewController {
    
    weak var stepDelegate: EditorStepDelegate?
    var viewModel: VideoEditingViewModel!
    
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    private let aspectRatioSegmentedControl = UISegmentedControl(items: VideoAspectRatio.allCases.map { $0.rawValue })
    private var aspectContainerConstraint: NSLayoutConstraint?
    
    private var templates: [FrameTemplate] = []
    private var selectedIndex: Int = 0
    private var videoThumbnail: UIImage?
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private let frameOverlayView = FrameOverlayView()
    private var playerObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Frame Templates"
        
        templates = TemplateManager.shared.frameTemplates()
        
        setupUI()
        setupAspectRatioControl()
        setupCollectionView()
        setupVideoPlayer()
        extractFirstFrameThumbnail()
        restoreExistingSelection()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
        frameOverlayView.frame = videoContainerView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
    
    private let liveLogoImageView = UIImageView()
    private let liveHeadlineBannerView = UIView()
    private let liveHeadlineLabel = UILabel()
    
    private func setupUI() {
        stepLabel.text = "Step 1 of \(viewModel?.totalSteps ?? 3): Choose Broadcast Template & Aspect Ratio"
        sectionTitleLabel.text = "SELECT BROADCAST TEMPLATE"
        
        // Video Container styling
        videoContainerView.backgroundColor = .black
        videoContainerView.layer.cornerRadius = 16
        videoContainerView.layer.masksToBounds = true
        
        // Overlay view on top of video container
        frameOverlayView.translatesAutoresizingMaskIntoConstraints = false
        videoContainerView.addSubview(frameOverlayView)
        
        // Live Logo Watermark overlay
        liveLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        liveLogoImageView.contentMode = .scaleAspectFit
        liveLogoImageView.clipsToBounds = true
        liveLogoImageView.isHidden = true
        videoContainerView.addSubview(liveLogoImageView)
        
        // Live Headline Ticker Banner overlay
        liveHeadlineBannerView.translatesAutoresizingMaskIntoConstraints = false
        liveHeadlineBannerView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        liveHeadlineBannerView.isHidden = true
        videoContainerView.addSubview(liveHeadlineBannerView)
        
        liveHeadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        liveHeadlineLabel.font = .systemFont(ofSize: 13, weight: .bold)
        liveHeadlineLabel.textColor = .white
        liveHeadlineLabel.textAlignment = .center
        liveHeadlineLabel.adjustsFontSizeToFitWidth = true
        liveHeadlineLabel.minimumScaleFactor = 0.8
        liveHeadlineBannerView.addSubview(liveHeadlineLabel)
        
        NSLayoutConstraint.activate([
            frameOverlayView.topAnchor.constraint(equalTo: videoContainerView.topAnchor),
            frameOverlayView.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor),
            frameOverlayView.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor),
            frameOverlayView.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor),
            
            liveLogoImageView.topAnchor.constraint(equalTo: videoContainerView.topAnchor, constant: 16),
            liveLogoImageView.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor, constant: 16),
            liveLogoImageView.widthAnchor.constraint(equalToConstant: 44),
            liveLogoImageView.heightAnchor.constraint(equalToConstant: 44),
            
            liveHeadlineBannerView.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor),
            liveHeadlineBannerView.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor),
            liveHeadlineBannerView.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor, constant: -20),
            liveHeadlineBannerView.heightAnchor.constraint(equalToConstant: 32),
            
            liveHeadlineLabel.centerYAnchor.constraint(equalTo: liveHeadlineBannerView.centerYAnchor),
            liveHeadlineLabel.leadingAnchor.constraint(equalTo: liveHeadlineBannerView.leadingAnchor, constant: 8),
            liveHeadlineLabel.trailingAnchor.constraint(equalTo: liveHeadlineBannerView.trailingAnchor, constant: -8)
        ])
        
        // Navigation Buttons
        backButton.layer.cornerRadius = 10
        skipButton.layer.cornerRadius = 10
        nextButton.layer.cornerRadius = 10
        
        if let vm = viewModel {
            backButton.isEnabled = !vm.isFirstStep
            backButton.alpha = vm.isFirstStep ? 0.5 : 1.0
        }
    }
    
    private func setupAspectRatioControl() {
        aspectRatioSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        aspectRatioSegmentedControl.selectedSegmentIndex = 0
        aspectRatioSegmentedControl.selectedSegmentTintColor = .systemBlue
        
        let normalTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: 12, weight: .medium)]
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 12, weight: .bold)]
        aspectRatioSegmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        aspectRatioSegmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        
        aspectRatioSegmentedControl.addTarget(self, action: #selector(aspectRatioChanged(_:)), for: .valueChanged)
        
        view.addSubview(aspectRatioSegmentedControl)
        
        NSLayoutConstraint.activate([
            aspectRatioSegmentedControl.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 8),
            aspectRatioSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            aspectRatioSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            aspectRatioSegmentedControl.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    @objc private func aspectRatioChanged(_ sender: UISegmentedControl) {
        let allRatios = VideoAspectRatio.allCases
        guard sender.selectedSegmentIndex < allRatios.count else { return }
        let selectedRatio = allRatios[sender.selectedSegmentIndex]
        viewModel?.setAspectRatio(selectedRatio)
        updateContainerAspectRatio(selectedRatio)
    }
    
    private func updateContainerAspectRatio(_ ratio: VideoAspectRatio) {
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 105, height: 135)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            FrameTemplateCell.self,
            forCellWithReuseIdentifier: FrameTemplateCell.reuseIdentifier
        )
    }
    
    private func setupVideoPlayer() {
        guard let videoURL = viewModel?.model.videoURL else { return }
        
        player = AVPlayer(url: videoURL)
        player?.isMuted = true
        
        let pLayer = AVPlayerLayer(player: player)
        pLayer.frame = videoContainerView.bounds
        pLayer.videoGravity = .resizeAspectFill
        videoContainerView.layer.insertSublayer(pLayer, at: 0)
        self.playerLayer = pLayer
        
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
    
    private func extractFirstFrameThumbnail() {
        guard let videoURL = viewModel?.model.videoURL else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset = AVURLAsset(url: videoURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: 240, height: 240)
            
            do {
                let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
                let image = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    self?.videoThumbnail = image
                    self?.collectionView.reloadData()
                }
            } catch {
                print("Error extracting thumbnail: \(error)")
            }
        }
    }
    
    private func restoreExistingSelection() {
        if let currentFrame = viewModel?.model.selectedFrame,
           let index = templates.firstIndex(where: { $0.id == currentFrame.id }) {
            selectedIndex = index
        } else {
            selectedIndex = 0
        }
        
        let currentRatio = viewModel?.model.aspectRatio ?? .original
        if let aspectIndex = VideoAspectRatio.allCases.firstIndex(of: currentRatio) {
            aspectRatioSegmentedControl.selectedSegmentIndex = aspectIndex
        }
        
        updateSelectedTemplatePreview()
        collectionView.reloadData()
    }
    
    private func updateSelectedTemplatePreview() {
        guard selectedIndex < templates.count else { return }
        let selectedTemplate = templates[selectedIndex]
        frameOverlayView.template = selectedTemplate
        
        // Auto select template default aspect ratio
        let defaultAspect = selectedTemplate.defaultAspect
        viewModel?.setAspectRatio(defaultAspect)
        if let aspectIndex = VideoAspectRatio.allCases.firstIndex(of: defaultAspect) {
            aspectRatioSegmentedControl.selectedSegmentIndex = aspectIndex
        }
        
        // Pre-fill default logo & headline from broadcast template
        if let logo = selectedTemplate.defaultLogo {
            let defaultFrame = CGRect(x: 16, y: 16, width: 60, height: 60)
            viewModel?.setLogo(image: logo, frame: defaultFrame)
            liveLogoImageView.image = logo
            liveLogoImageView.isHidden = false
        } else if let existingLogo = viewModel?.model.logoImage {
            liveLogoImageView.image = existingLogo
            liveLogoImageView.isHidden = false
        } else {
            liveLogoImageView.isHidden = true
        }
        
        if let headline = selectedTemplate.defaultHeadline {
            viewModel?.setHeadline(text: headline)
            liveHeadlineLabel.text = headline
            liveHeadlineBannerView.isHidden = false
        } else if let existingHeadline = viewModel?.model.headlineText {
            liveHeadlineLabel.text = existingHeadline
            liveHeadlineBannerView.isHidden = false
        } else {
            liveHeadlineBannerView.isHidden = true
        }
        
        applyHeadlineAnimation(style: selectedTemplate.headlineStyle)
    }
    
    private func applyHeadlineAnimation(style: HeadlineAnimationStyle) {
        liveHeadlineLabel.layer.removeAllAnimations()
        liveLogoImageView.layer.removeAllAnimations()
        
        switch style {
        case .slidingTicker:
            let bannerWidth = videoContainerView.bounds.width > 0 ? videoContainerView.bounds.width : 360.0
            let animation = CABasicAnimation(keyPath: "transform.translation.x")
            animation.fromValue = bannerWidth
            animation.toValue = -bannerWidth * 1.2
            animation.duration = 6.5
            animation.repeatCount = .infinity
            liveHeadlineLabel.layer.add(animation, forKey: "marqueeTicker")
            
        case .pulsingBadge:
            let bannerWidth = videoContainerView.bounds.width > 0 ? videoContainerView.bounds.width : 360.0
            let marquee = CABasicAnimation(keyPath: "transform.translation.x")
            marquee.fromValue = bannerWidth
            marquee.toValue = -bannerWidth * 1.2
            marquee.duration = 6.5
            marquee.repeatCount = .infinity
            liveHeadlineLabel.layer.add(marquee, forKey: "marqueeTicker")
            
            let pulse = CABasicAnimation(keyPath: "transform.scale")
            pulse.fromValue = 1.0
            pulse.toValue = 1.15
            pulse.duration = 0.6
            pulse.autoreverses = true
            pulse.repeatCount = .infinity
            liveLogoImageView.layer.add(pulse, forKey: "logoPulse")
            
        case .staticCentered:
            liveHeadlineLabel.transform = .identity
            liveLogoImageView.transform = .identity
        }
    }
    
    // MARK: - Actions
    
    @IBAction func backTapped(_ sender: UIButton) {
        stepDelegate?.stepDidTapBack(self)
    }
    
    @IBAction func skipTapped(_ sender: UIButton) {
        viewModel?.clearFrame()
        stepDelegate?.stepDidTapSkip(self)
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        applyToViewModel()
        stepDelegate?.stepDidTapNext(self)
    }
    
    func applyToViewModel() {
        if selectedIndex < templates.count {
            let template = templates[selectedIndex]
            if template.style == .none {
                viewModel?.clearFrame()
            } else {
                viewModel?.setFrame(template)
            }
        } else {
            viewModel?.clearFrame()
        }
    }
    
    deinit {
        if let observer = playerObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        player?.pause()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension FrameTemplatesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return templates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FrameTemplateCell.reuseIdentifier,
            for: indexPath
        ) as! FrameTemplateCell
        
        let template = templates[indexPath.item]
        let isSelected = (indexPath.item == selectedIndex)
        cell.configure(with: template, videoThumbnail: videoThumbnail, isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        updateSelectedTemplatePreview()
        collectionView.reloadData()
    }
}
