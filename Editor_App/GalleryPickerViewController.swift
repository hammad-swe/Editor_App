//
//  GalleryPickerViewController.swift
//  Editor_App
//
//  Created by Hammad Ali on 18/08/2026.
//

import UIKit
import Photos

protocol GalleryPickerDelegate: AnyObject {
    func galleryPicker(_ picker: GalleryPickerViewController, didSelect asset: PHAsset)
}

class GalleryPickerViewController: UIViewController {
    
    var filter: GalleryFilter = .video
    weak var delegate: GalleryPickerDelegate?
    
    private var fetchResult: PHFetchResult<PHAsset>!
    private var collectionView: UICollectionView!
    private var selectedIndexPath: IndexPath?
    
    private let cellID = "PickerCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = filter == .photo ? "Select Photo" : "Select Video"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "checkmark"),
            style: .done,
            target: self,
            action: #selector(tickTapped)
        )
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        setupCollectionView()
        loadAssets()
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
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PickerCell.self, forCellWithReuseIdentifier: cellID)
        view.addSubview(collectionView)
    }
    
    private func loadAssets() {
        fetchResult = GalleryManager.shared.fetchAssets(filter: filter)
        collectionView.reloadData()
    }
    
    @objc private func tickTapped() {
        guard let indexPath = selectedIndexPath else { return }
        let asset = fetchResult.object(at: indexPath.item)
        delegate?.galleryPicker(self, didSelect: asset)
    }
}

extension GalleryPickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PickerCell
        let asset = fetchResult.object(at: indexPath.item)
        cell.configure(with: asset, isSelected: indexPath == selectedIndexPath)
        return cell
    }
}

extension GalleryPickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previous = selectedIndexPath
        selectedIndexPath = (selectedIndexPath == indexPath) ? nil : indexPath
        
        var toReload = [indexPath]
        if let previous = previous { toReload.append(previous) }
        collectionView.reloadItems(at: toReload)
        
        navigationItem.rightBarButtonItem?.isEnabled = (selectedIndexPath != nil)
    }
}

// MARK: - Cell with selection checkmark overlay

class PickerCell: UICollectionViewCell {
    
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
    
    func configure(with asset: PHAsset, isSelected: Bool) {
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

