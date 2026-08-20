//
//  RecentProjectDashboardCell.swift
//  Editor_App
//
//  Created by Antigravity on 20/08/2026.
//

import UIKit

class RecentProjectDashboardCell: UICollectionViewCell {
    
    static let reuseIdentifier = "RecentProjectDashboardCell"
    
    private let cardContainerView = UIView()
    private let thumbnailImageView = UIImageView()
    private let playIconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        contentView.backgroundColor = .clear
        
        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        cardContainerView.layer.cornerRadius = 14
        cardContainerView.layer.masksToBounds = true
        cardContainerView.backgroundColor = .secondarySystemGroupedBackground
        cardContainerView.layer.borderWidth = 1.0
        cardContainerView.layer.borderColor = UIColor.separator.cgColor
        contentView.addSubview(cardContainerView)
        
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.backgroundColor = .black
        cardContainerView.addSubview(thumbnailImageView)
        
        // Dark gradient overlay on thumbnail
        let playCircle = UIView()
        playCircle.translatesAutoresizingMaskIntoConstraints = false
        playCircle.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        playCircle.layer.cornerRadius = 18
        playCircle.clipsToBounds = true
        thumbnailImageView.addSubview(playCircle)
        
        playIconImageView.translatesAutoresizingMaskIntoConstraints = false
        playIconImageView.image = UIImage(systemName: "play.fill")
        playIconImageView.tintColor = .white
        playCircle.addSubview(playIconImageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        cardContainerView.addSubview(titleLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 11, weight: .regular)
        dateLabel.textColor = .secondaryLabel
        cardContainerView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            cardContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            thumbnailImageView.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalTo: cardContainerView.heightAnchor, multiplier: 0.65),
            
            playCircle.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor),
            playCircle.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor),
            playCircle.widthAnchor.constraint(equalToConstant: 36),
            playCircle.heightAnchor.constraint(equalToConstant: 36),
            
            playIconImageView.centerXAnchor.constraint(equalTo: playCircle.centerXAnchor, constant: 1),
            playIconImageView.centerYAnchor.constraint(equalTo: playCircle.centerYAnchor),
            playIconImageView.widthAnchor.constraint(equalToConstant: 16),
            playIconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -8),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardContainerView.bottomAnchor, constant: -6)
        ])
    }
    
    func configure(with project: EditedVideoProject) {
        titleLabel.text = project.title
        thumbnailImageView.image = project.thumbnailImage
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: project.createdAt)
    }
}
