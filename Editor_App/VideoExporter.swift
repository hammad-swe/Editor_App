//
//  VideoExporter.swift
//  Editor_App
//
//  Created by Hammad Ali on 18/08/2026.
//

import AVFoundation
import UIKit

final class VideoExporter {
    
    static let shared = VideoExporter()
    private init() {}
    
    func export(
        videoURL: URL,
        frameTemplate: FrameTemplate? = nil,
        customFrameColor: UIColor? = nil,
        customBorderWidth: CGFloat? = nil,
        customCornerRadius: CGFloat? = nil,
        aspectRatio: VideoAspectRatio = .original,
        icon: UIImage?,
        iconFrame: CGRect,
        logoShape: LogoShape = .square,
        logoPositionRatio: CGPoint = CGPoint(x: 0.05, y: 0.05),
        headlineText: String?,
        headlineFont: UIFont,
        previewBounds: CGRect,
        completion: @escaping (URL?) -> Void
    ) {
        let asset = AVURLAsset(url: videoURL)
        
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            completion(nil); return
        }
        
        let composition = AVMutableComposition()
        guard let compVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion(nil); return
        }
        
        do {
            let range = CMTimeRange(start: .zero, duration: asset.duration)
            try compVideoTrack.insertTimeRange(range, of: videoTrack, at: .zero)
            
            if let audioTrack = asset.tracks(withMediaType: .audio).first,
               let compAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
                try compAudioTrack.insertTimeRange(range, of: audioTrack, at: .zero)
            }
        } catch {
            print("Composition error: \(error)")
            completion(nil); return
        }
        
        let naturalSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
        var videoSize = CGSize(width: abs(naturalSize.width), height: abs(naturalSize.height))
        
        // Calculate target render size based on aspect ratio
        if let targetRatio = aspectRatio.ratioValue {
            let currentRatio = videoSize.width / videoSize.height
            if currentRatio > targetRatio {
                videoSize = CGSize(width: videoSize.height * targetRatio, height: videoSize.height)
            } else {
                videoSize = CGSize(width: videoSize.width, height: videoSize.width / targetRatio)
            }
        }
        
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
        
        // 0. Frame Template Layer
        if let frame = frameTemplate, frame.style != .none {
            let widthRatio = videoSize.width / 300.0
            let frameColor = customFrameColor ?? frame.borderColor
            let effectiveBorderWidth = customBorderWidth ?? frame.borderWidth
            let effectiveCornerRadius = customCornerRadius ?? frame.cornerRadius
            
            switch frame.style {
            case .none:
                break
                
            case .classic:
                let borderLayer = CALayer()
                let bWidth = max(6.0, effectiveBorderWidth * widthRatio)
                borderLayer.frame = CGRect(origin: .zero, size: videoSize)
                borderLayer.borderColor = frameColor.cgColor
                borderLayer.borderWidth = bWidth
                overlayLayer.addSublayer(borderLayer)
                
            case .cinematic:
                let barHeight = videoSize.height * 0.12
                let topBar = CALayer()
                topBar.frame = CGRect(x: 0, y: videoSize.height - barHeight, width: videoSize.width, height: barHeight)
                topBar.backgroundColor = UIColor.black.cgColor
                overlayLayer.addSublayer(topBar)
                
                let bottomBar = CALayer()
                bottomBar.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: barHeight)
                bottomBar.backgroundColor = UIColor.black.cgColor
                overlayLayer.addSublayer(bottomBar)
                
            case .rounded:
                let borderLayer = CALayer()
                let bWidth = max(6.0, effectiveBorderWidth * widthRatio)
                let cRadius = effectiveCornerRadius * widthRatio
                borderLayer.frame = CGRect(origin: .zero, size: videoSize)
                borderLayer.borderColor = frameColor.cgColor
                borderLayer.borderWidth = bWidth
                borderLayer.cornerRadius = cRadius
                overlayLayer.addSublayer(borderLayer)
                
            case .polaroid:
                let sideBorder = 14.0 * widthRatio
                let bottomBorder = 52.0 * widthRatio
                
                let topBar = CALayer()
                topBar.frame = CGRect(x: 0, y: videoSize.height - sideBorder, width: videoSize.width, height: sideBorder)
                topBar.backgroundColor = UIColor.white.cgColor
                overlayLayer.addSublayer(topBar)
                
                let leftBar = CALayer()
                leftBar.frame = CGRect(x: 0, y: 0, width: sideBorder, height: videoSize.height)
                leftBar.backgroundColor = UIColor.white.cgColor
                overlayLayer.addSublayer(leftBar)
                
                let rightBar = CALayer()
                rightBar.frame = CGRect(x: videoSize.width - sideBorder, y: 0, width: sideBorder, height: videoSize.height)
                rightBar.backgroundColor = UIColor.white.cgColor
                overlayLayer.addSublayer(rightBar)
                
                let bottomBar = CALayer()
                bottomBar.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: bottomBorder)
                bottomBar.backgroundColor = UIColor.white.cgColor
                overlayLayer.addSublayer(bottomBar)
                
            case .neonGlow:
                let borderLayer = CALayer()
                let bWidth = max(5.0, effectiveBorderWidth * widthRatio)
                let cRadius = effectiveCornerRadius * widthRatio
                borderLayer.frame = CGRect(origin: .zero, size: videoSize)
                borderLayer.borderColor = frameColor.cgColor
                borderLayer.borderWidth = bWidth
                borderLayer.cornerRadius = cRadius
                borderLayer.shadowColor = frameColor.cgColor
                borderLayer.shadowRadius = 15.0 * widthRatio
                borderLayer.shadowOpacity = 0.9
                borderLayer.shadowOffset = .zero
                overlayLayer.addSublayer(borderLayer)
                
            case .vintage:
                let borderLayer = CALayer()
                let bWidth = max(6.0, effectiveBorderWidth * widthRatio)
                borderLayer.frame = CGRect(origin: .zero, size: videoSize)
                borderLayer.borderColor = frameColor.cgColor
                borderLayer.borderWidth = bWidth
                overlayLayer.addSublayer(borderLayer)
                
                let innerBorder = CALayer()
                let innerInset = bWidth + (4.0 * widthRatio)
                innerBorder.frame = CGRect(
                    x: innerInset,
                    y: innerInset,
                    width: videoSize.width - innerInset * 2,
                    height: videoSize.height - innerInset * 2
                )
                innerBorder.borderColor = UIColor(red: 0.95, green: 0.85, blue: 0.6, alpha: 0.7).cgColor
                innerBorder.borderWidth = max(2.0, 2.0 * widthRatio)
                overlayLayer.addSublayer(innerBorder)
                
            case .newsBroadcast:
                let borderLayer = CALayer()
                borderLayer.frame = CGRect(origin: .zero, size: videoSize)
                borderLayer.borderColor = (customFrameColor ?? UIColor.systemRed).cgColor
                borderLayer.borderWidth = max(6.0, effectiveBorderWidth * widthRatio)
                overlayLayer.addSublayer(borderLayer)
                
                let topBar = CALayer()
                topBar.frame = CGRect(x: 0, y: videoSize.height - (32.0 * widthRatio), width: videoSize.width, height: 32.0 * widthRatio)
                topBar.backgroundColor = (customFrameColor ?? UIColor.systemRed).cgColor
                overlayLayer.addSublayer(topBar)
                
            case .sportsBroadcast:
                let sportsColor = customFrameColor ?? UIColor(red: 0.1, green: 0.2, blue: 0.5, alpha: 1.0)
                let borderLayer = CALayer()
                borderLayer.frame = CGRect(origin: .zero, size: videoSize)
                borderLayer.borderColor = sportsColor.cgColor
                borderLayer.borderWidth = max(6.0, effectiveBorderWidth * widthRatio)
                overlayLayer.addSublayer(borderLayer)
                
                let topBar = CALayer()
                topBar.frame = CGRect(x: 0, y: videoSize.height - (30.0 * widthRatio), width: videoSize.width, height: 30.0 * widthRatio)
                topBar.backgroundColor = sportsColor.cgColor
                overlayLayer.addSublayer(topBar)
                
            case .podcastShow:
                let podcastColor = customFrameColor ?? UIColor(red: 0.4, green: 0.1, blue: 0.6, alpha: 1.0)
                let borderLayer = CALayer()
                borderLayer.frame = CGRect(origin: .zero, size: videoSize)
                borderLayer.borderColor = podcastColor.cgColor
                borderLayer.borderWidth = max(6.0, effectiveBorderWidth * widthRatio)
                borderLayer.cornerRadius = 16.0 * widthRatio
                overlayLayer.addSublayer(borderLayer)
                
            case .minimal:
                let borderLayer = CALayer()
                borderLayer.frame = CGRect(origin: .zero, size: videoSize)
                borderLayer.borderColor = frameColor.cgColor
                borderLayer.borderWidth = max(3.0, effectiveBorderWidth * widthRatio)
                borderLayer.cornerRadius = effectiveCornerRadius * widthRatio
                overlayLayer.addSublayer(borderLayer)
                
            case .gradient:
                let borderLayer = CALayer()
                borderLayer.frame = CGRect(origin: .zero, size: videoSize)
                borderLayer.borderColor = frameColor.cgColor
                borderLayer.borderWidth = max(6.0, effectiveBorderWidth * widthRatio)
                borderLayer.cornerRadius = effectiveCornerRadius * widthRatio
                borderLayer.shadowColor = UIColor.systemPink.cgColor
                borderLayer.shadowRadius = 12.0 * widthRatio
                borderLayer.shadowOpacity = 0.8
                overlayLayer.addSublayer(borderLayer)
                
            case .filmStrip:
                let barWidth = 14.0 * widthRatio
                let leftBar = CALayer()
                leftBar.frame = CGRect(x: 0, y: 0, width: barWidth, height: videoSize.height)
                leftBar.backgroundColor = UIColor.black.cgColor
                overlayLayer.addSublayer(leftBar)
                
                let rightBar = CALayer()
                rightBar.frame = CGRect(x: videoSize.width - barWidth, y: 0, width: barWidth, height: videoSize.height)
                rightBar.backgroundColor = UIColor.black.cgColor
                overlayLayer.addSublayer(rightBar)
                
            case .glitch:
                let borderLayer = CALayer()
                borderLayer.frame = CGRect(origin: .zero, size: videoSize)
                borderLayer.borderColor = frameColor.cgColor
                borderLayer.borderWidth = max(4.0, effectiveBorderWidth * widthRatio)
                borderLayer.cornerRadius = effectiveCornerRadius * widthRatio
                overlayLayer.addSublayer(borderLayer)
                
            case .splitDual:
                let borderLayer = CALayer()
                borderLayer.frame = CGRect(origin: .zero, size: videoSize)
                borderLayer.borderColor = frameColor.cgColor
                borderLayer.borderWidth = max(4.0, effectiveBorderWidth * widthRatio)
                overlayLayer.addSublayer(borderLayer)
                
                let splitLine = CALayer()
                let midX = videoSize.width / 2.0
                splitLine.frame = CGRect(x: midX - 2.0, y: 0, width: 4.0, height: videoSize.height)
                splitLine.backgroundColor = frameColor.cgColor
                overlayLayer.addSublayer(splitLine)
            }
        }
        
        // 1. Icon Watermark Layer
        if let icon = icon {
            let format = UIGraphicsImageRendererFormat()
            format.scale = 2.0
            format.opaque = false
            let iconRenderer = UIGraphicsImageRenderer(size: icon.size, format: format)
            let renderedImage = iconRenderer.image { _ in
                icon.draw(in: CGRect(origin: .zero, size: icon.size))
            }
            
            if let cgImage = renderedImage.cgImage {
                let iconLayer = CALayer()
                iconLayer.contents = cgImage
                iconLayer.contentsGravity = .resizeAspect
                
                let logoSize = min(videoSize.width, videoSize.height) * 0.18
                let posX = logoPositionRatio.x * (videoSize.width - logoSize)
                let posY = videoSize.height - logoSize - (logoPositionRatio.y * (videoSize.height - logoSize))
                
                iconLayer.frame = CGRect(
                    x: max(0, min(videoSize.width - logoSize, posX)),
                    y: max(0, min(videoSize.height - logoSize, posY)),
                    width: logoSize,
                    height: logoSize
                )
                
                // Shape Masking
                switch logoShape {
                case .square:
                    break
                case .circle:
                    iconLayer.cornerRadius = logoSize / 2.0
                    iconLayer.masksToBounds = true
                case .roundedSquare:
                    iconLayer.cornerRadius = logoSize * 0.2
                    iconLayer.masksToBounds = true
                case .hexagon, .diamond:
                    let shapeMask = CAShapeLayer()
                    let rect = CGRect(origin: .zero, size: CGSize(width: logoSize, height: logoSize))
                    let path = UIBezierPath()
                    if logoShape == .diamond {
                        path.move(to: CGPoint(x: rect.midX, y: 0))
                        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
                        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
                        path.addLine(to: CGPoint(x: 0, y: rect.midY))
                        path.close()
                    } else { // hexagon
                        let side = logoSize / 2.0
                        path.move(to: CGPoint(x: rect.midX, y: 0))
                        path.addLine(to: CGPoint(x: rect.maxX, y: logoSize * 0.25))
                        path.addLine(to: CGPoint(x: rect.maxX, y: logoSize * 0.75))
                        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
                        path.addLine(to: CGPoint(x: 0, y: logoSize * 0.75))
                        path.addLine(to: CGPoint(x: 0, y: logoSize * 0.25))
                        path.close()
                    }
                    shapeMask.path = path.cgPath
                    iconLayer.mask = shapeMask
                }
                
                overlayLayer.addSublayer(iconLayer)
            }
        }
        
        // 2. Headline Text Layer - Clean Full Width Ticker (No RED Live Badge)
        if let headlineText = headlineText, !headlineText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let trimmedText = headlineText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let fontSize = max(24, videoSize.height * 0.05)
            let fontName = headlineFont.fontName
            
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: fontName, size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize)
            ]
            let textSize = (trimmedText as NSString).size(withAttributes: textAttributes)
            
            let bannerHeight = max(textSize.height * 1.6, videoSize.height * 0.09)
            let bannerY = videoSize.height * 0.06
            
            // Full-width dark semi-transparent ticker bar
            let bannerLayer = CALayer()
            bannerLayer.frame = CGRect(x: 0, y: bannerY, width: videoSize.width, height: bannerHeight)
            bannerLayer.backgroundColor = UIColor.black.withAlphaComponent(0.70).cgColor
            bannerLayer.masksToBounds = true
            overlayLayer.addSublayer(bannerLayer)
            
            let tickerAreaX: CGFloat = 0
            let tickerAreaWidth = videoSize.width
            
            let textLayer = CATextLayer()
            textLayer.string = trimmedText
            textLayer.font = fontName as NSString
            textLayer.fontSize = fontSize
            textLayer.foregroundColor = UIColor.white.cgColor
            textLayer.contentsScale = 2.0
            
            let textY = (bannerHeight - textSize.height) / 2
            
            if textSize.width > tickerAreaWidth - 40 {
                // LONG TEXT: Sliding ticker animation across the full width
                let textWidth = textSize.width + 40
                textLayer.alignmentMode = .left
                textLayer.frame = CGRect(x: 0, y: textY, width: textWidth, height: textSize.height + 10)
                
                let duration = CMTimeGetSeconds(asset.duration)
                let marquee = CABasicAnimation(keyPath: "position.x")
                marquee.fromValue = tickerAreaWidth + textWidth / 2
                marquee.toValue = -textWidth / 2
                marquee.duration = max(5.0, Double(textWidth / 100.0))
                marquee.repeatCount = duration > 0 ? Float(duration / marquee.duration) : 100
                marquee.beginTime = AVCoreAnimationBeginTimeAtZero // AVVideoComposition requirement!
                marquee.isRemovedOnCompletion = false
                marquee.fillMode = .forwards
                
                let tickerContainer = CALayer()
                tickerContainer.frame = CGRect(x: tickerAreaX, y: 0, width: tickerAreaWidth, height: bannerHeight)
                tickerContainer.masksToBounds = true
                tickerContainer.addSublayer(textLayer)
                bannerLayer.addSublayer(tickerContainer)
                
                textLayer.add(marquee, forKey: "marquee")
            } else {
                // SHORT TEXT: Clean centered display across full width
                textLayer.alignmentMode = .center
                textLayer.frame = CGRect(x: tickerAreaX, y: textY, width: tickerAreaWidth, height: textSize.height + 10)
                bannerLayer.addSublayer(textLayer)
            }
        }
        
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(origin: .zero, size: videoSize)
        
        let parentLayer = CALayer()
        parentLayer.frame = CGRect(origin: .zero, size: videoSize)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer)
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compVideoTrack)
        layerInstruction.setTransform(videoTrack.preferredTransform, at: .zero)
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil); return
        }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov
        exportSession.videoComposition = videoComposition
        
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                completion(exportSession.status == .completed ? outputURL : nil)
            }
        }
    }
}
