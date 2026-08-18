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
    
    private let cellID = "AssetCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = initialFilter == .photo ? "Photos" : "Videos"
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
        collectionView.register(AssetCell.self, forCellWithReuseIdentifier: cellID)
        view.addSubview(collectionView)
    }
    
    private func loadAssets() {
        fetchResult = GalleryManager.shared.fetchAssets(filter: initialFilter)
        collectionView.reloadData()
    }
}

extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! AssetCell
        let asset = fetchResult.object(at: indexPath.item)
        cell.configure(with: asset)
        return cell
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = fetchResult.object(at: indexPath.item)
        // TODO: push a detail screen, branching on asset.mediaType (.image vs .video)
    }
}

// MARK: - Cell (defined in the same file to keep this a single drop-in unit)

class AssetCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    private let durationLabel = UILabel()
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
        
        durationLabel.font = .systemFont(ofSize: 11, weight: .medium)
        durationLabel.textColor = .white
        durationLabel.textAlignment = .right
        durationLabel.frame = CGRect(x: contentView.bounds.width - 44, y: contentView.bounds.height - 18, width: 40, height: 16)
        durationLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        contentView.addSubview(durationLabel)
    }
    
    func configure(with asset: PHAsset) {
        currentAssetID = asset.localIdentifier
        imageView.image = nil
        
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
