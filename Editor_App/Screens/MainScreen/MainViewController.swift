//
//  MainViewController.swift
//  Editor_App
//
//  Created by Hammad Ali on 17/08/2026.
//

import UIKit
import PhotosUI
import Photos
import AVKit

class MainViewController: UIViewController {
    
    // Outlets maintained for backward-compatibility with existing XIB
    @IBOutlet weak var cardView: UIStackView?
    @IBOutlet weak var videoView: UIStackView?
    @IBOutlet weak var photoView: UIStackView?
    @IBOutlet weak var CollegeView: UIStackView?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private var recentProjects: [EditedVideoProject] = []
    private var recentProjectsCollectionView: UICollectionView!
    private let emptyRecentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        buildModernDashboardUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRecentProjects()
    }
    
    private func setupNavigationBar() {
        title = "Editor Studio"
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let settingButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape.fill"),
            style: .plain,
            target: self,
            action: #selector(rightButtonTapped)
        )
        settingButton.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = settingButton
    }
    
    @objc func rightButtonTapped() {
        let vc = SettingViewController(nibName: "SettingViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func buildModernDashboardUI() {
        view.backgroundColor = .systemGroupedBackground
        
        // Hide existing static stack view from XIB if present
        cardView?.superview?.isHidden = true
        
        // Setup root scrollview
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // 1. Hero Banner
        let heroBanner = createHeroBanner()
        contentView.addSubview(heroBanner)
        
        // 2. Section: Create New
        let createNewHeader = createSectionHeader(title: "CREATE NEW", actionTitle: nil, action: nil)
        contentView.addSubview(createNewHeader)
        
        // 3. Primary Video Card
        let videoCard = createPrimaryVideoCard()
        contentView.addSubview(videoCard)
        
        // 4. Secondary Cards (Photo & Collage)
        let secondaryCardsStack = createSecondaryCardsStack()
        contentView.addSubview(secondaryCardsStack)
        
        // 5. Section: Recent Projects
        let recentHeader = createSectionHeader(
            title: "RECENT PROJECTS",
            actionTitle: "See All",
            action: #selector(seeAllProjectsTapped)
        )
        contentView.addSubview(recentHeader)
        
        // 6. Recent Projects Collection View
        setupRecentProjectsCollectionView()
        contentView.addSubview(recentProjectsCollectionView)
        contentView.addSubview(emptyRecentView)
        setupEmptyRecentView()
        
        NSLayoutConstraint.activate([
            heroBanner.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            heroBanner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            heroBanner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            createNewHeader.topAnchor.constraint(equalTo: heroBanner.bottomAnchor, constant: 24),
            createNewHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            createNewHeader.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            videoCard.topAnchor.constraint(equalTo: createNewHeader.bottomAnchor, constant: 12),
            videoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            videoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            videoCard.heightAnchor.constraint(equalToConstant: 120),
            
            secondaryCardsStack.topAnchor.constraint(equalTo: videoCard.bottomAnchor, constant: 12),
            secondaryCardsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            secondaryCardsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            secondaryCardsStack.heightAnchor.constraint(equalToConstant: 95),
            
            recentHeader.topAnchor.constraint(equalTo: secondaryCardsStack.bottomAnchor, constant: 24),
            recentHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            recentHeader.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            recentProjectsCollectionView.topAnchor.constraint(equalTo: recentHeader.bottomAnchor, constant: 12),
            recentProjectsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            recentProjectsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            recentProjectsCollectionView.heightAnchor.constraint(equalToConstant: 160),
            
            emptyRecentView.topAnchor.constraint(equalTo: recentHeader.bottomAnchor, constant: 12),
            emptyRecentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emptyRecentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emptyRecentView.heightAnchor.constraint(equalToConstant: 110),
            emptyRecentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    // MARK: - UI Builder Components
    
    private func createHeroBanner() -> UIView {
        let banner = UIView()
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.layer.cornerRadius = 20
        banner.clipsToBounds = true
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.12, green: 0.28, blue: 0.65, alpha: 1.0).cgColor,
            UIColor(red: 0.25, green: 0.50, blue: 0.95, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 140)
        banner.layer.insertSublayer(gradientLayer, at: 0)
        
        let badge = UILabel()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.text = " STUDIO PRO "
        badge.font = .systemFont(ofSize: 11, weight: .bold)
        badge.textColor = .white
        badge.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        badge.layer.cornerRadius = 6
        badge.clipsToBounds = true
        banner.addSubview(badge)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Video & Photo Editor"
        titleLabel.font = .systemFont(ofSize: 22, weight: .heavy)
        titleLabel.textColor = .white
        banner.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Add templates, custom frames, logos & live ticker banners"
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        subtitleLabel.numberOfLines = 2
        banner.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            banner.heightAnchor.constraint(equalToConstant: 130),
            
            badge.topAnchor.constraint(equalTo: banner.topAnchor, constant: 16),
            badge.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 18),
            badge.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -18),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 18),
            subtitleLabel.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -18)
        ])
        
        return banner
    }
    
    private func createSectionHeader(title: String, actionTitle: String?, action: Selector?) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .secondaryLabel
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            container.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        if let actionTitle = actionTitle, let action = action {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(actionTitle, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            button.setTitleColor(.systemBlue, for: .normal)
            button.addTarget(self, action: action, for: .touchUpInside)
            container.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                button.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
        }
        
        return container
    }
    
    private func createPrimaryVideoCard() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1.5
        card.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        
        // Icon container
        let iconBg = UIView()
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        iconBg.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        iconBg.layer.cornerRadius = 24
        card.addSubview(iconBg)
        
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = UIImage(systemName: "video.badge.plus")
        icon.tintColor = .systemBlue
        icon.contentMode = .scaleAspectFit
        iconBg.addSubview(icon)
        
        // Titles
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Video Editor"
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .label
        card.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Browse library"
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        card.addSubview(subtitleLabel)
        
        let ctaButton = UIButton(type: .system)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.setTitle("Create Video  ›", for: .normal)
        ctaButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.backgroundColor = .systemBlue
        ctaButton.layer.cornerRadius = 8
        ctaButton.isUserInteractionEnabled = false // let card tap handle it
        card.addSubview(ctaButton)
        
        NSLayoutConstraint.activate([
            iconBg.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconBg.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 48),
            iconBg.heightAnchor.constraint(equalToConstant: 48),
            
            icon.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: ctaButton.leadingAnchor, constant: -8),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 14),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: ctaButton.leadingAnchor, constant: -8),
            
            ctaButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            ctaButton.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            ctaButton.widthAnchor.constraint(equalToConstant: 110),
            ctaButton.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(videoCardTapped))
        card.addGestureRecognizer(tap)
        card.isUserInteractionEnabled = true
        
        return card
    }
    
    private func createSecondaryCardsStack() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        
        let photoCard = createSmallFeatureCard(
            title: "Photos",
            subtitle: "Browse library",
            systemIcon: "photo.on.rectangle.angled",
            tintColor: .systemGreen,
            action: #selector(photoCardTapped)
        )
        
        let collageCard = createSmallFeatureCard(
            title: "Collage",
            subtitle: "Combine media",
            systemIcon: "square.grid.2x2.fill",
            tintColor: .systemOrange,
            action: #selector(collegeCardTapped)
        )
        
        stack.addArrangedSubview(photoCard)
        stack.addArrangedSubview(collageCard)
        return stack
    }
    
    private func createSmallFeatureCard(
        title: String,
        subtitle: String,
        systemIcon: String,
        tintColor: UIColor,
        action: Selector
    ) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 14
        card.layer.borderWidth = 1.0
        card.layer.borderColor = UIColor.separator.cgColor
        
        let iconBg = UIView()
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        iconBg.backgroundColor = tintColor.withAlphaComponent(0.12)
        iconBg.layer.cornerRadius = 18
        card.addSubview(iconBg)
        
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = UIImage(systemName: systemIcon)
        icon.tintColor = tintColor
        icon.contentMode = .scaleAspectFit
        iconBg.addSubview(icon)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = .label
        card.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 11, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        card.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            iconBg.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            iconBg.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 36),
            iconBg.heightAnchor.constraint(equalToConstant: 36),
            
            icon.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),
            
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 10),
            subtitleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: action)
        card.addGestureRecognizer(tap)
        card.isUserInteractionEnabled = true
        return card
    }
    
    private func setupRecentProjectsCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150, height: 155)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        recentProjectsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        recentProjectsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        recentProjectsCollectionView.backgroundColor = .clear
        recentProjectsCollectionView.showsHorizontalScrollIndicator = false
        recentProjectsCollectionView.delegate = self
        recentProjectsCollectionView.dataSource = self
        recentProjectsCollectionView.register(
            RecentProjectDashboardCell.self,
            forCellWithReuseIdentifier: RecentProjectDashboardCell.reuseIdentifier
        )
    }
    
    private func setupEmptyRecentView() {
        emptyRecentView.translatesAutoresizingMaskIntoConstraints = false
        emptyRecentView.backgroundColor = .secondarySystemGroupedBackground
        emptyRecentView.layer.cornerRadius = 14
        emptyRecentView.layer.borderWidth = 1.0
        emptyRecentView.layer.borderColor = UIColor.separator.cgColor
        
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        emptyRecentView.addSubview(stack)
        
        let icon = UIImageView(image: UIImage(systemName: "film.stack"))
        icon.tintColor = .systemGray3
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.heightAnchor.constraint(equalToConstant: 28).isActive = true
        stack.addArrangedSubview(icon)
        
        let titleLabel = UILabel()
        titleLabel.text = "No Saved Projects Yet"
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        stack.addArrangedSubview(titleLabel)
        
        let subLabel = UILabel()
        subLabel.text = "Tap Video Editor above to create your first video!"
        subLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subLabel.textColor = .tertiaryLabel
        stack.addArrangedSubview(subLabel)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: emptyRecentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: emptyRecentView.centerYAnchor)
        ])
    }
    
    private func loadRecentProjects() {
        recentProjects = CoreDataManager.shared.fetchAllProjects()
        let hasProjects = !recentProjects.isEmpty
        recentProjectsCollectionView.isHidden = !hasProjects
        emptyRecentView.isHidden = hasProjects
        recentProjectsCollectionView.reloadData()
    }
    
    // MARK: - Actions
    
    @objc private func seeAllProjectsTapped() {
        let vc = MyProjectsViewController(nibName: "MyProjectsViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func photoCardTapped() {
        openGallery(filter: .photo)
    }
    
    @objc private func videoCardTapped() {
        GalleryManager.shared.requestAccess { [weak self] granted in
            guard let self = self else { return }
            if granted {
                let picker = GalleryPickerViewController()
                picker.filter = .video
                picker.delegate = self
                self.navigationController?.pushViewController(picker, animated: true)
            } else {
                self.showPermissionDeniedAlert()
            }
        }
    }
    
    @objc private func collegeCardTapped() {
        openGallery(filter: .photo)
    }
    
    private func openGallery(filter: GalleryFilter) {
        GalleryManager.shared.requestAccess { [weak self] granted in
            guard let self = self else { return }
            if granted {
                let vc = GalleryViewController()
                vc.initialFilter = filter
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.showPermissionDeniedAlert()
            }
        }
    }
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Photo Access Needed",
            message: "Please enable photo library access in Settings to view your photos and videos.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate (Recent Projects)

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(recentProjects.count, 6)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RecentProjectDashboardCell.reuseIdentifier,
            for: indexPath
        ) as! RecentProjectDashboardCell
        
        let project = recentProjects[indexPath.item]
        cell.configure(with: project)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let project = recentProjects[indexPath.item]
        guard let videoURL = project.fullVideoURL else { return }
        
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
    }
}

// MARK: - GalleryPickerDelegate

extension MainViewController: GalleryPickerDelegate {
    func galleryPicker(_ picker: GalleryPickerViewController, didSelect asset: PHAsset) {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.center = picker.view.center
        spinner.startAnimating()
        picker.view.addSubview(spinner)
        picker.navigationItem.rightBarButtonItem?.isEnabled = false
        
        VideoStorageManager.shared.saveVideo(from: asset) { [weak self] localURL in
            spinner.stopAnimating()
            spinner.removeFromSuperview()
            
            guard let self = self, let localURL = localURL else {
                let alert = UIAlertController(
                    title: "Error",
                    message: "Couldn't load this video. Try another one.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                picker.present(alert, animated: true)
                picker.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }
            
            let editVC = EditingViewController()
            editVC.videoURL = localURL
            self.navigationController?.pushViewController(editVC, animated: true)
        }
    }
}
