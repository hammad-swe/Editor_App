//
//  VideoEditingModel.swift
//  Editor_App
//
//  Created by Antigravity on 18/08/2026.
//

import UIKit
import AVFoundation

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
    var rotationDegrees: Int = 0     // 0, 90, 180, 270 degrees clockwise
    var cropRect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1) // normalized crop rect (0.0 - 1.0)
    
    // Trim & Cut properties
    var trimStartTime: CMTime = .zero
    var trimEndTime: CMTime? = nil
    
    // Audio Management properties
    var muteOriginalAudio: Bool = false
    var replacementAudioURL: URL? = nil
    var replacementAudioVolume: Float = 1.0
}
