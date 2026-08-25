//
//  FrameTemplateCell.swift
//  Editor_App
//
//  Created by Antigravity on 20/08/2026.
//

import UIKit

class FrameTemplateCell: UICollectionViewCell {
    
    static let reuseIdentifier = "FrameTemplateCell"
    
    private let cardContainerView = UIView()
    private let thumbnailImageView = UIImageView()
    private let frameOverlayView = FrameOverlayView()
    private let miniLogoImageView = UIImageView()
    private let miniHeadlineBanner = UIView()
    private let miniHeadlineLabel = UILabel()
    private let titleLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    
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
        
        // Card container
        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        cardContainerView.layer.cornerRadius = 12
        cardContainerView.layer.masksToBounds = true
        cardContainerView.backgroundColor = .systemGray6
        contentView.addSubview(cardContainerView)
        
        // Video first frame thumbnail
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.backgroundColor = .black
        cardContainerView.addSubview(thumbnailImageView)
        
        // Overlay view on top of thumbnail
        frameOverlayView.translatesAutoresizingMaskIntoConstraints = false
        cardContainerView.addSubview(frameOverlayView)
        
        // Mini Logo watermark preview on thumbnail
        miniLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        miniLogoImageView.contentMode = .scaleAspectFit
        miniLogoImageView.clipsToBounds = true
        miniLogoImageView.isHidden = true
        cardContainerView.addSubview(miniLogoImageView)
        
        // Mini Headline Banner preview on thumbnail
        miniHeadlineBanner.translatesAutoresizingMaskIntoConstraints = false
        miniHeadlineBanner.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        miniHeadlineBanner.isHidden = true
        cardContainerView.addSubview(miniHeadlineBanner)
        
        miniHeadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        miniHeadlineLabel.font = .systemFont(ofSize: 8, weight: .bold)
        miniHeadlineLabel.textColor = .white
        miniHeadlineLabel.textAlignment = .center
        miniHeadlineBanner.addSubview(miniHeadlineLabel)
        
        // Checkmark badge for selected state
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        checkmarkImageView.tintColor = .systemBlue
        checkmarkImageView.backgroundColor = .white
        checkmarkImageView.layer.cornerRadius = 10
        checkmarkImageView.clipsToBounds = true
        checkmarkImageView.isHidden = true
        cardContainerView.addSubview(checkmarkImageView)
        
        // Title Label under card
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            cardContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            cardContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            cardContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            cardContainerView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -6),
            
            thumbnailImageView.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor),
            
            frameOverlayView.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
            frameOverlayView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            frameOverlayView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            frameOverlayView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor),
            
            miniLogoImageView.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 6),
            miniLogoImageView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 6),
            miniLogoImageView.widthAnchor.constraint(equalToConstant: 18),
            miniLogoImageView.heightAnchor.constraint(equalToConstant: 18),
            
            miniHeadlineBanner.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            miniHeadlineBanner.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            miniHeadlineBanner.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: -8),
            miniHeadlineBanner.heightAnchor.constraint(equalToConstant: 14),
            
            miniHeadlineLabel.centerYAnchor.constraint(equalTo: miniHeadlineBanner.centerYAnchor),
            miniHeadlineLabel.leadingAnchor.constraint(equalTo: miniHeadlineBanner.leadingAnchor, constant: 2),
            miniHeadlineLabel.trailingAnchor.constraint(equalTo: miniHeadlineBanner.trailingAnchor, constant: -2),
            
            checkmarkImageView.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 6),
            checkmarkImageView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -6),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            titleLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    func configure(with template: FrameTemplate, videoThumbnail: UIImage?, isSelected: Bool) {
        titleLabel.text = template.name
        thumbnailImageView.image = videoThumbnail
        frameOverlayView.template = template
        
        // Display default logo icon on card thumbnail
        if let defaultLogo = template.defaultLogo {
            miniLogoImageView.image = defaultLogo
            miniLogoImageView.isHidden = false
        } else {
            miniLogoImageView.isHidden = true
        }
        
        // Display default headline preview tag on card thumbnail
        if let defaultHeadline = template.defaultHeadline {
            miniHeadlineLabel.text = defaultHeadline
            miniHeadlineBanner.isHidden = false
        } else {
            miniHeadlineBanner.isHidden = true
        }
        
        if isSelected {
            cardContainerView.layer.borderWidth = 2.5
            cardContainerView.layer.borderColor = UIColor.systemBlue.cgColor
            checkmarkImageView.isHidden = false
            titleLabel.textColor = .systemBlue
            titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        } else {
            cardContainerView.layer.borderWidth = 1.0
            cardContainerView.layer.borderColor = UIColor.separator.cgColor
            checkmarkImageView.isHidden = true
            titleLabel.textColor = .label
            titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        }
    }
}
