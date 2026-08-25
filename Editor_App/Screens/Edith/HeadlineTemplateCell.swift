//
//  HeadlineTemplateCell.swift
//  Editor_App
//
//  Created by Antigravity on 19/08/2026.
//

import UIKit

class HeadlineTemplateCell: UITableViewCell {

    @IBOutlet weak var templateNameLabel: UILabel!
    @IBOutlet weak var previewTextLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with template: HeadlineTemplate, isSelected: Bool) {
        templateNameLabel.text = template.name
        previewTextLabel.text = "\"\(template.text)\""
        previewTextLabel.font = template.font
        previewTextLabel.textColor = template.textColor
        checkmarkImageView.isHidden = !isSelected
        contentView.backgroundColor = isSelected ? UIColor.systemBlue.withAlphaComponent(0.1) : .clear
    }
}
