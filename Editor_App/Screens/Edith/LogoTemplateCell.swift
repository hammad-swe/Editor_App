//
//  LogoTemplateCell.swift
//  Editor_App
//
//  Created by Antigravity on 19/08/2026.
//

import UIKit

class LogoTemplateCell: UITableViewCell {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        logoImageView.layer.cornerRadius = 6
        logoImageView.clipsToBounds = true
        logoImageView.contentMode = .scaleAspectFit
    }

    func configure(with template: LogoTemplate, isSelected: Bool) {
        logoImageView.image = template.image
        nameLabel.text = template.name
        checkmarkImageView.isHidden = !isSelected
        contentView.backgroundColor = isSelected ? UIColor.systemBlue.withAlphaComponent(0.1) : .clear
    }
}
