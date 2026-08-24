//
//  ActionTemplateCell.swift
//  Editor_App
//
//  Created by Antigravity on 21/08/2026.
//

import UIKit

class ActionTemplateCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ActionTemplateCell"
    
    private let cardContainerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    
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
        cardContainerView.layer.cornerRadius = 10
        cardContainerView.layer.masksToBounds = true
        cardContainerView.layer.borderWidth = 1.0
        cardContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        cardContainerView.backgroundColor = .secondarySystemGroupedBackground
        contentView.addSubview(cardContainerView)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        cardContainerView.addSubview(iconImageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            cardContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            cardContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            cardContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            cardContainerView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -4),
            
            iconImageView.centerXAnchor.constraint(equalTo: cardContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: cardContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            titleLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func configure(title: String, systemIcon: String, badgeColor: UIColor) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: systemIcon)
        iconImageView.tintColor = badgeColor
        cardContainerView.backgroundColor = badgeColor.withAlphaComponent(0.12)
        cardContainerView.layer.borderColor = badgeColor.withAlphaComponent(0.4).cgColor
    }
}
