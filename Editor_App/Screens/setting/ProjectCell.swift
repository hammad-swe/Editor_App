//
//  ProjectCell.swift
//  Editor_App
//
//  Created by Antigravity on 19/08/2026.
//

import UIKit

class ProjectCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        thumbnailImageView.layer.cornerRadius = 8
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.contentMode = .scaleAspectFill
    }

    func configure(with project: EditedVideoProject) {
        titleLabel.text = project.title
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: project.createdAt)
        
        if let thumb = project.thumbnailImage {
            thumbnailImageView.image = thumb
        } else {
            thumbnailImageView.image = UIImage(systemName: "video.fill")
        }
    }
}
