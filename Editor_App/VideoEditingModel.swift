//
//  VideoEditingModel.swift
//  Editor_App
//
//  Created by Antigravity on 18/08/2026.
//

import UIKit

struct VideoEditingModel {
    var videoURL: URL
    var selectedFrame: FrameTemplate? // nil or .none = no frame
    var customFrameColor: UIColor?   // custom override frame border color
    var customBorderWidth: CGFloat?  // custom override border width
    var customCornerRadius: CGFloat? // custom override corner radius
    var aspectRatio: VideoAspectRatio = .original
    var logoImage: UIImage?          // nil = no logo (skipped or removed)
    var logoFrame: CGRect = .zero    // position in preview coordinates
    var logoShape: LogoShape = .square
    var logoPositionRatio: CGPoint = CGPoint(x: 0.05, y: 0.05) // normalized top-left position (0.0 - 1.0)
    var headlineText: String?        // nil = no headline (skipped or cleared)
    var headlineFont: UIFont = .systemFont(ofSize: 17, weight: .bold)
    var coverImage: UIImage?         // cover thumbnail photo
}
