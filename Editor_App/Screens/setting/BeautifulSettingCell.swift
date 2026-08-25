//
//  BeautifulSettingCell.swift
//  Editor_App
//
//  Created by Antigravity on 20/08/2026.
//

import UIKit

class BeautifulSettingCell: UITableViewCell {
    
    static let reuseIdentifier = "BeautifulSettingCell"
    
    private let iconContainerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let valueLabel = UILabel()
    private let labelStack = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .secondarySystemGroupedBackground
        
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconContainerView.layer.cornerRadius = 9
        iconContainerView.clipsToBounds = true
        contentView.addSubview(iconContainerView)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconContainerView.addSubview(iconImageView)
        
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        labelStack.axis = .vertical
        labelStack.spacing = 2
        labelStack.alignment = .leading
        contentView.addSubview(labelStack)
        
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label
        labelStack.addArrangedSubview(titleLabel)
        
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        labelStack.addArrangedSubview(subtitleLabel)
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        valueLabel.textColor = .secondaryLabel
        valueLabel.textAlignment = .right
        contentView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            iconContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 34),
            iconContainerView.heightAnchor.constraint(equalToConstant: 34),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),
            
            labelStack.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 14),
            labelStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelStack.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -8),
            
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(
        title: String,
        subtitle: String?,
        value: String?,
        systemIcon: String,
        badgeColor: UIColor,
        showDisclosure: Bool = true
    ) {
        titleLabel.text = title
        
        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
        
        if let value = value {
            valueLabel.text = value
            valueLabel.isHidden = false
        } else {
            valueLabel.isHidden = true
        }
        
        iconContainerView.backgroundColor = badgeColor.withAlphaComponent(0.18)
        iconImageView.image = UIImage(systemName: systemIcon)
        iconImageView.tintColor = badgeColor
        
        accessoryType = showDisclosure ? .disclosureIndicator : .none
    }
}
