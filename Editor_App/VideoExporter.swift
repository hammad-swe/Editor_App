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
        icon: UIImage,
        iconFrame: CGRect,
        headlineText: String,
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
        
        // Scale overlay coordinates from preview screen size -> actual video pixel size
        let scaleX = videoSize.width / previewBounds.width
        let scaleY = videoSize.height / previewBounds.height
        
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
        
        // Icon watermark layer
        let iconLayer = CALayer()
        iconLayer.contents = icon.cgImage
        iconLayer.frame = CGRect(
            x: iconFrame.origin.x * scaleX,
            y: videoSize.height - (iconFrame.origin.y * scaleY) - (iconFrame.height * scaleY),
            width: iconFrame.width * scaleX,
            height: iconFrame.height * scaleY
        )
        overlayLayer.addSublayer(iconLayer)
        
        // Headline text layer with scrolling animation
        let textLayer = CATextLayer()
        textLayer.string = headlineText
        textLayer.font = headlineFont
        textLayer.fontSize = headlineFont.pointSize * scaleY
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.alignmentMode = .left
        textLayer.contentsScale = UIScreen.main.scale
        
        let textWidth = (headlineText as NSString).size(withAttributes: [.font: headlineFont]).width * scaleX
        textLayer.frame = CGRect(x: videoSize.width, y: videoSize.height - (60 * scaleY), width: textWidth, height: 40 * scaleY)
        
        let duration = CMTimeGetSeconds(asset.duration)
        let marquee = CABasicAnimation(keyPath: "position.x")
        marquee.fromValue = videoSize.width + textWidth / 2
        marquee.toValue = -textWidth / 2
        marquee.duration = 6.0
        marquee.repeatCount = Float(duration / 6.0)
        marquee.isRemovedOnCompletion = false
        marquee.fillMode = .forwards
        textLayer.add(marquee, forKey: "marquee")
        
        overlayLayer.addSublayer(textLayer)
        
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
