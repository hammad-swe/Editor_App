//
//  FrameTemplatesViewController.swift
//  Editor_App
//
//  Created by Antigravity on 20/08/2026.
//

import UIKit
import AVFoundation
import PhotosUI

class FrameTemplatesViewController: UIViewController, EditorStepViewController {
    
    weak var stepDelegate: EditorStepDelegate?
    var viewModel: VideoEditingViewModel!
    
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var videoContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    private let aspectRatioSegmentedControl = UISegmentedControl(items: VideoAspectRatio.allCases.map { $0.rawValue })
    
    private var templates: [FrameTemplate] = []
    private var selectedIndex: Int = 0
    private var videoThumbnail: UIImage?
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private let coverImageView = UIImageView()
    private let coverPlayIcon = UIImageView()
    private let frameOverlayView = FrameOverlayView()
    private var playerObserver: NSObjectProtocol?
    
    private let liveLogoImageView = UIImageView()
    private let liveHeadlineBannerView = UIView()
    private let liveHeadlineLabel = UILabel()
    
    // Logo position constraints for drag-and-drop
    private var logoTopConstraint: NSLayoutConstraint?
    private var logoLeadingConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Frame Templates"
        
        loadTemplates()
        
        setupUI()
        setupCoverView()
        setupAspectRatioControl()
        setupCollectionView()
        setupVideoPlayer()
        setupLogoDragAndDrop()
        extractFirstFrameThumbnail()
        restoreExistingSelection()
    }
    
    private func loadTemplates() {
        templates = TemplateManager.shared.allTemplates()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
        coverImageView.frame = videoContainerView.bounds
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
    
    private func setupUI() {
        stepLabel.text = "Step 1 of \(viewModel?.totalSteps ?? 3): Choose Broadcast Template & Aspect Ratio"
        sectionTitleLabel.text = "SELECT BROADCAST TEMPLATE"
        
        // Video Container styling - Larger Default View
        videoContainerView.backgroundColor = .black
        videoContainerView.layer.cornerRadius = 16
        videoContainerView.layer.masksToBounds = true
        videoContainerHeightConstraint.constant = 320
        
        // Overlay view on top of video container
        frameOverlayView.translatesAutoresizingMaskIntoConstraints = false
        videoContainerView.addSubview(frameOverlayView)
        
        // Live Logo Watermark overlay (Interactive for Drag-and-Drop)
        liveLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        liveLogoImageView.contentMode = .scaleAspectFit
        liveLogoImageView.clipsToBounds = true
        liveLogoImageView.isUserInteractionEnabled = true
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
        
        logoTopConstraint = liveLogoImageView.topAnchor.constraint(equalTo: videoContainerView.topAnchor, constant: 16)
        logoLeadingConstraint = liveLogoImageView.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor, constant: 16)
        
        NSLayoutConstraint.activate([
            frameOverlayView.topAnchor.constraint(equalTo: videoContainerView.topAnchor),
            frameOverlayView.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor),
            frameOverlayView.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor),
            frameOverlayView.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor),
            
            logoTopConstraint!,
            logoLeadingConstraint!,
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
        
        // Tap video container to toggle play/pause & hide cover
        let containerTap = UITapGestureRecognizer(target: self, action: #selector(videoContainerTapped))
        videoContainerView.addGestureRecognizer(containerTap)
    }
    
    // MARK: - Cover View Setup
    
    private func setupCoverView() {
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.isHidden = true
        videoContainerView.insertSubview(coverImageView, belowSubview: frameOverlayView)
        
        coverPlayIcon.image = UIImage(systemName: "play.circle.fill")
        coverPlayIcon.tintColor = .white
        coverPlayIcon.contentMode = .scaleAspectFit
        coverPlayIcon.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.addSubview(coverPlayIcon)
        
        NSLayoutConstraint.activate([
            coverPlayIcon.centerXAnchor.constraint(equalTo: coverImageView.centerXAnchor),
            coverPlayIcon.centerYAnchor.constraint(equalTo: coverImageView.centerYAnchor),
            coverPlayIcon.widthAnchor.constraint(equalToConstant: 50),
            coverPlayIcon.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func videoContainerTapped() {
        if !coverImageView.isHidden {
            UIView.animate(withDuration: 0.3) {
                self.coverImageView.alpha = 0
            } completion: { _ in
                self.coverImageView.isHidden = true
                self.coverImageView.alpha = 1
                self.player?.play()
            }
        } else {
            if player?.timeControlStatus == .playing {
                player?.pause()
            } else {
                player?.play()
            }
        }
    }
    
    // MARK: - Aspect Ratio Control (Relocated Below Frames)
    
    private func setupAspectRatioControl() {
        aspectRatioSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        aspectRatioSegmentedControl.selectedSegmentIndex = 0
        aspectRatioSegmentedControl.selectedSegmentTintColor = .systemBlue
        
        let normalTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: 11, weight: .medium)]
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 11, weight: .bold)]
        aspectRatioSegmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        aspectRatioSegmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        
        aspectRatioSegmentedControl.addTarget(self, action: #selector(aspectRatioChanged(_:)), for: .valueChanged)
        
        view.addSubview(aspectRatioSegmentedControl)
        
        NSLayoutConstraint.activate([
            aspectRatioSegmentedControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 12),
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
        
        // Refresh Video in Video View when user clicks aspect ratio
        player?.seek(to: .zero)
        player?.play()
    }
    
    private func updateContainerAspectRatio(_ ratio: VideoAspectRatio) {
        // Outer video container height is FIXED at 320pt
        if videoContainerHeightConstraint != nil {
            videoContainerHeightConstraint.constant = 320
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
            self.playerLayer?.frame = self.videoContainerView.bounds
            self.playerLayer?.videoGravity = .resizeAspect
            self.coverImageView.frame = self.videoContainerView.bounds
            self.frameOverlayView.frame = self.videoContainerView.bounds
        }
    }
    
    // MARK: - Logo Drag and Drop Setup
    
    private func setupLogoDragAndDrop() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleLogoPan(_:)))
        liveLogoImageView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handleLogoPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: videoContainerView)
        guard let viewToDrag = gesture.view else { return }
        
        var newCenterX = viewToDrag.center.x + translation.x
        var newCenterY = viewToDrag.center.y + translation.y
        
        let halfWidth = viewToDrag.bounds.width / 2.0
        let halfHeight = viewToDrag.bounds.height / 2.0
        
        // Clamp bounds inside container
        newCenterX = max(halfWidth, min(videoContainerView.bounds.width - halfWidth, newCenterX))
        newCenterY = max(halfHeight, min(videoContainerView.bounds.height - halfHeight, newCenterY))
        
        viewToDrag.center = CGPoint(x: newCenterX, y: newCenterY)
        gesture.setTranslation(.zero, in: videoContainerView)
        
        if gesture.state == .ended || gesture.state == .changed {
            let originX = newCenterX - halfWidth
            let originY = newCenterY - halfHeight
            
            logoLeadingConstraint?.constant = originX
            logoTopConstraint?.constant = originY
            
            let maxMarginX = max(1, videoContainerView.bounds.width - viewToDrag.bounds.width)
            let maxMarginY = max(1, videoContainerView.bounds.height - viewToDrag.bounds.height)
            
            let ratioX = originX / maxMarginX
            let ratioY = originY / maxMarginY
            
            viewModel?.setLogoPositionRatio(CGPoint(x: ratioX, y: ratioY))
        }
    }
    
    private func applyLogoShapeMask(_ shape: LogoShape) {
        liveLogoImageView.layer.mask = nil
        liveLogoImageView.layer.cornerRadius = 0
        
        switch shape {
        case .square:
            break
        case .circle:
            liveLogoImageView.layer.cornerRadius = liveLogoImageView.bounds.width / 2.0
            liveLogoImageView.clipsToBounds = true
        case .roundedSquare:
            liveLogoImageView.layer.cornerRadius = 10
            liveLogoImageView.clipsToBounds = true
        case .hexagon, .diamond:
            let shapeMask = CAShapeLayer()
            let rect = liveLogoImageView.bounds
            let path = UIBezierPath()
            if shape == .diamond {
                path.move(to: CGPoint(x: rect.midX, y: 0))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
                path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
                path.addLine(to: CGPoint(x: 0, y: rect.midY))
                path.close()
            } else { // hexagon
                path.move(to: CGPoint(x: rect.midX, y: 0))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.height * 0.25))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.height * 0.75))
                path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
                path.addLine(to: CGPoint(x: 0, y: rect.height * 0.75))
                path.addLine(to: CGPoint(x: 0, y: rect.height * 0.25))
                path.close()
            }
            shapeMask.path = path.cgPath
            liveLogoImageView.layer.mask = shapeMask
        }
    }
    
    // MARK: - Collection View Setup
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 105)
        layout.minimumLineSpacing = 8
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
        collectionView.register(
            ActionTemplateCell.self,
            forCellWithReuseIdentifier: ActionTemplateCell.reuseIdentifier
        )
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleCellLongPress(_:)))
        collectionView.addGestureRecognizer(longPress)
    }
    
    @objc private func handleCellLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let point = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            let templateIndex = indexPath.item - 1
            if templateIndex >= 0 && templateIndex < templates.count {
                let template = templates[templateIndex]
                if !template.isBuiltIn {
                    let alert = UIAlertController(title: "Delete Custom Template", message: "Are you sure you want to delete '\(template.name)'?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                        CustomTemplateStorage.shared.deleteTemplate(id: template.id)
                        self?.loadTemplates()
                        self?.collectionView.reloadData()
                    }))
                    present(alert, animated: true)
                }
            }
        }
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
                    if self?.viewModel?.model.coverImage == nil {
                        self?.coverImageView.image = image
                    }
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
        
        updateContainerAspectRatio(currentRatio)
        updateSelectedTemplatePreview()
        collectionView.reloadData()
    }
    
    private func updateSelectedTemplatePreview() {
        guard selectedIndex < templates.count else { return }
        let selectedTemplate = templates[selectedIndex]
        frameOverlayView.template = selectedTemplate
        
        // Pre-fill default logo & headline from broadcast template if user hasn't overridden
        if let logo = selectedTemplate.defaultLogo {
            let defaultFrame = CGRect(x: 16, y: 16, width: 44, height: 44)
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
        
        applyLogoShapeMask(viewModel.model.logoShape)
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
    
    // MARK: - Action Handlers (Cover & Customization Sheet)
    
    private func presentCoverPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func presentCustomizationSheet() {
        let sheetVC = FrameCustomizationSheetViewController()
        sheetVC.delegate = self
        sheetVC.currentColor = frameOverlayView.customBorderColor ?? templates[selectedIndex].borderColor
        sheetVC.currentBorderWidth = viewModel.model.customBorderWidth ?? templates[selectedIndex].borderWidth
        sheetVC.currentCornerRadius = viewModel.model.customCornerRadius ?? templates[selectedIndex].cornerRadius
        sheetVC.currentLogoShape = viewModel.model.logoShape
        
        if let sheet = sheetVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(sheetVC, animated: true)
    }
    
    // MARK: - Navigation Actions
    
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
        // Index 0: Cover, Index 1...count: Templates, Index count+1: Customize
        return templates.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            // Cover Action Cell
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ActionTemplateCell.reuseIdentifier,
                for: indexPath
            ) as! ActionTemplateCell
            cell.configure(title: "Cover", systemIcon: "photo.on.rectangle.angled", badgeColor: .systemPurple)
            return cell
        } else if indexPath.item == templates.count + 1 {
            // Customize Action Cell
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ActionTemplateCell.reuseIdentifier,
                for: indexPath
            ) as! ActionTemplateCell
            cell.configure(title: "Customize", systemIcon: "paintpalette.fill", badgeColor: .systemOrange)
            return cell
        } else {
            // Frame Template Cell
            let templateIndex = indexPath.item - 1
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FrameTemplateCell.reuseIdentifier,
                for: indexPath
            ) as! FrameTemplateCell
            
            let template = templates[templateIndex]
            let isSelected = (templateIndex == selectedIndex)
            cell.configure(with: template, videoThumbnail: videoThumbnail, isSelected: isSelected)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            presentCoverPicker()
        } else if indexPath.item == templates.count + 1 {
            presentCustomizationSheet()
        } else {
            selectedIndex = indexPath.item - 1
            updateSelectedTemplatePreview()
            collectionView.reloadData()
        }
    }
}

// MARK: - PHPickerViewControllerDelegate (Cover Image)

extension FrameTemplatesViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            if let image = image as? UIImage {
                DispatchQueue.main.async {
                    self?.coverImageView.image = image
                    self?.coverImageView.isHidden = false
                    self?.player?.pause()
                    self?.viewModel?.setCoverImage(image)
                }
            }
        }
    }
}

// MARK: - FrameCustomizationDelegate

extension FrameTemplatesViewController: FrameCustomizationDelegate {
    func customizationDidChange(color: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat, logoShape: LogoShape) {
        frameOverlayView.customBorderColor = color
        viewModel?.setCustomFrameColor(color)
        viewModel?.setCustomBorderWidth(borderWidth)
        viewModel?.setCustomCornerRadius(cornerRadius)
        viewModel?.setLogoShape(logoShape)
        applyLogoShapeMask(logoShape)
    }
    
    func customizationDidResetLogoPosition() {
        logoLeadingConstraint?.constant = 16
        logoTopConstraint?.constant = 16
        UIView.animate(withDuration: 0.3) {
            self.videoContainerView.layoutIfNeeded()
        }
        viewModel?.setLogoPositionRatio(CGPoint(x: 0.05, y: 0.05))
    }
    
    func customizationDidRequestSaveTemplate(name: String) {
        let currentTemplate = templates[selectedIndex]
        let colorHex = (frameOverlayView.customBorderColor ?? currentTemplate.borderColor).toHex()
        
        let saved = SavedCustomTemplate(
            id: UUID().uuidString,
            name: name,
            styleRaw: currentTemplate.style.rawValue,
            borderColorHex: colorHex,
            borderWidth: viewModel.model.customBorderWidth ?? currentTemplate.borderWidth,
            cornerRadius: viewModel.model.customCornerRadius ?? currentTemplate.cornerRadius,
            defaultAspectRaw: viewModel.model.aspectRatio.rawValue,
            logoShapeRaw: viewModel.model.logoShape.rawValue,
            logoPositionX: viewModel.model.logoPositionRatio.x,
            logoPositionY: viewModel.model.logoPositionRatio.y,
            headlineText: viewModel.model.headlineText,
            createdAt: Date()
        )
        
        CustomTemplateStorage.shared.saveTemplate(saved)
        loadTemplates()
        selectedIndex = templates.count - 1
        updateSelectedTemplatePreview()
        collectionView.reloadData()
    }
}
