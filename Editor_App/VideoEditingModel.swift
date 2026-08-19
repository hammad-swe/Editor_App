//
//  VideoEditingModel.swift
//  Editor_App
//
//  Created by Antigravity on 18/08/2026.
//

import UIKit

struct VideoEditingModel {
    var videoURL: URL
    var logoImage: UIImage?          // nil = no logo (skipped or removed)
    var logoFrame: CGRect = .zero    // position in preview coordinates
    var headlineText: String?        // nil = no headline (skipped or cleared)
    var headlineFont: UIFont = .systemFont(ofSize: 17, weight: .bold)
}
