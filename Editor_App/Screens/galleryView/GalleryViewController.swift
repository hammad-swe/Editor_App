//
//  GalleryViewController.swift
//  Editor_App
//
//  Created by Hammad Ali on 17/08/2026.
//

import UIKit
import Photos

class GalleryViewController: UIViewController {
    
    var initialFilter: GalleryFilter = .photo
    private var fetchResult: PHFetchResult<PHAsset>!
    private var collectionView: UICollectionView!
    private var selectedIndexPath: IndexPath?
    
    private let bottomContainerView = UIView()
    private let bottomNextButton = UIButton(type: .system)
    
    private let cellID = "AssetCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = initialFilter == .photo ? "Photos" : "Videos"
        
       // setupNavItems()
        setupCollectionView()
        setupBottomBar()
        loadAssets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupNavItems() {
//        let nextItem = UIBarButtonItem(
//            title: "Next",
//            style: .done,
//            target: self,
//            action: #selector(nextTapped)
//        )
//        let font = UIFont.systemFont(ofSize: 16, weight: .bold)
//        nextItem.setTitleTextAttributes([.font: font, .foregroundColor: UIColor.systemBlue], for: .normal)
//        nextItem.setTitleTextAttributes([.font: font, .foregroundColor: UIColor.systemGray3], for: .disabled)
//        nextItem.isEnabled = false
//        navigationItem.rightBarButtonItem = nextItem
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 2
        let itemsPerRow: CGFloat = 3
        let totalSpacing = spacing * (itemsPerRow - 1)
        let width = (view.frame.width - totalSpacing) / itemsPerRow
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(AssetCell.self, forCellWithReuseIdentifier: cellID)
        view.addSubview(collectionView)
    }
    
    private func setupBottomBar() {
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.backgroundColor = .secondarySystemGroupedBackground
        bottomContainerView.layer.shadowColor = UIColor.black.cgColor
        bottomContainerView.layer.shadowOpacity = 0.1
        bottomContainerView.layer.shadowOffset = CGSize(width: 0, height: -2)
        bottomContainerView.layer.shadowRadius = 8
        view.addSubview(bottomContainerView)
        
        bottomNextButton.translatesAutoresizingMaskIntoConstraints = false
        bottomNextButton.setTitle("Select & Edit Video  ›", for: .normal)
        bottomNextButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        bottomNextButton.setTitleColor(.white, for: .normal)
        bottomNextButton.backgroundColor = .systemBlue
        bottomNextButton.layer.cornerRadius = 12
        bottomNextButton.isEnabled = false
        bottomNextButton.alpha = 0.5
        bottomNextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        bottomContainerView.addSubview(bottomNextButton)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            
            bottomContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomContainerView.heightAnchor.constraint(equalToConstant: 90),
            
            bottomNextButton.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 12),
            bottomNextButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 16),
            bottomNextButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -16),
            bottomNextButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func loadAssets() {
        fetchResult = GalleryManager.shared.fetchAssets(filter: initialFilter)
        collectionView.reloadData()
    }
    
    @objc private func nextTapped() {
        guard let indexPath = selectedIndexPath else { return }
        let asset = fetchResult.object(at: indexPath.item)
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.center = view.center
        spinner.startAnimating()
        view.addSubview(spinner)
        navigationItem.rightBarButtonItem?.isEnabled = false
        bottomNextButton.isEnabled = false
        
        VideoStorageManager.shared.saveVideo(from: asset) { [weak self] localURL in
            DispatchQueue.main.async {
                spinner.stopAnimating()
                spinner.removeFromSuperview()
                
                guard let self = self, let localURL = localURL else {
                    let alert = UIAlertController(title: "Error", message: "Couldn't load selected media.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                    self?.updateSelectionState()
                    return
                }
                
                let editVC = EditingViewController(nibName: "EditingViewController", bundle: nil)
                editVC.videoURL = localURL
                self.navigationController?.pushViewController(editVC, animated: true)
            }
        }
    }
    
    private func updateSelectionState() {
        let isSelected = (selectedIndexPath != nil)
        navigationItem.rightBarButtonItem?.isEnabled = isSelected
        bottomNextButton.isEnabled = isSelected
        bottomNextButton.alpha = isSelected ? 1.0 : 0.5
    }
}

extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! AssetCell
        let asset = fetchResult.object(at: indexPath.item)
        cell.configure(with: asset, isSelected: indexPath == selectedIndexPath)
        return cell
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previous = selectedIndexPath
        if selectedIndexPath == indexPath {
            selectedIndexPath = nil
        } else {
            selectedIndexPath = indexPath
        }
        
        var toReload = [indexPath]
        if let previous = previous { toReload.append(previous) }
        collectionView.reloadItems(at: toReload)
        
        updateSelectionState()
    }
}

// MARK: - Cell (with selection checkmark overlay)

class AssetCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    private let durationLabel = UILabel()
    private let checkmarkView = UIImageView()
    private let dimOverlay = UIView()
    private var currentAssetID: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        imageView.frame = contentView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        dimOverlay.frame = contentView.bounds
        dimOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        dimOverlay.isHidden = true
        contentView.addSubview(dimOverlay)
        
        durationLabel.font = .systemFont(ofSize: 11, weight: .medium)
        durationLabel.textColor = .white
        durationLabel.textAlignment = .right
        durationLabel.frame = CGRect(x: contentView.bounds.width - 44, y: contentView.bounds.height - 18, width: 40, height: 16)
        durationLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        contentView.addSubview(durationLabel)
        
        checkmarkView.image = UIImage(systemName: "checkmark.circle.fill")
        checkmarkView.tintColor = .systemBlue
        checkmarkView.backgroundColor = .white
        checkmarkView.layer.cornerRadius = 10
        checkmarkView.frame = CGRect(x: contentView.bounds.width - 24, y: 4, width: 20, height: 20)
        checkmarkView.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        checkmarkView.isHidden = true
        contentView.addSubview(checkmarkView)
    }
    
    func configure(with asset: PHAsset, isSelected: Bool = false) {
        currentAssetID = asset.localIdentifier
        imageView.image = nil
        checkmarkView.isHidden = !isSelected
        dimOverlay.isHidden = !isSelected
        
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: bounds.width * scale, height: bounds.height * scale)
        
        GalleryManager.shared.requestThumbnail(for: asset, targetSize: targetSize) { [weak self] image in
            guard let self = self, self.currentAssetID == asset.localIdentifier else { return }
            self.imageView.image = image
        }
        
        if asset.mediaType == .video {
            durationLabel.isHidden = false
            let mins = Int(asset.duration) / 60
            let secs = Int(asset.duration) % 60
            durationLabel.text = String(format: "%d:%02d", mins, secs)
        } else {
            durationLabel.isHidden = true
        }
    }
}
