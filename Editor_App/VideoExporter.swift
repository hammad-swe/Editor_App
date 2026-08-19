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
        icon: UIImage?,
        iconFrame: CGRect,
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
        let videoSize = CGSize(width: abs(naturalSize.width), height: abs(naturalSize.height))
        
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
        
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
                let padding = logoSize * 0.3
                
                iconLayer.frame = CGRect(
                    x: padding,
                    y: videoSize.height - logoSize - padding,
                    width: logoSize,
                    height: logoSize
                )
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
