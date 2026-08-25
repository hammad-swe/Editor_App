//
//  VideoEditingViewModel.swift
//  Editor_App
//
//  Created by Antigravity on 18/08/2026.
//

import UIKit
import AVFoundation

final class VideoEditingViewModel {
    
    private(set) var model: VideoEditingModel
    var currentStepIndex: Int = 0
    let totalSteps: Int = 5
    
    var isFirstStep: Bool { currentStepIndex == 0 }
    var isLastStep: Bool { currentStepIndex == totalSteps - 1 }
    
    init(videoURL: URL) {
        self.model = VideoEditingModel(videoURL: videoURL)
    }
    
    // MARK: - Transform & Crop Helpers
    
    func applyModelTransforms(to playerLayer: AVPlayerLayer?) {
        guard let playerLayer = playerLayer else { return }
        let degrees = model.rotationDegrees
        let radians = CGFloat(degrees) * .pi / 180.0
        playerLayer.transform = CATransform3DMakeRotation(radians, 0, 0, 1)
        playerLayer.contentsRect = model.cropRect
    }
    
    // MARK: - Video Cut & Split
    
    func setTrimRange(start: CMTime, end: CMTime?) {
        model.trimStartTime = start
        model.trimEndTime = end
    }
    
    // MARK: - Audio Management
    
    func setMuteOriginalAudio(_ muted: Bool) {
        model.muteOriginalAudio = muted
    }
    
    func setReplacementAudio(url: URL?, volume: Float = 1.0) {
        model.replacementAudioURL = url
        model.replacementAudioVolume = volume
    }
    
    // MARK: - Frame Template Editing
    
    func setFrame(_ frame: FrameTemplate?) {
        model.selectedFrame = frame
    }
    
    func clearFrame() {
        model.selectedFrame = nil
    }
    
    func setAspectRatio(_ ratio: VideoAspectRatio) {
        model.aspectRatio = ratio
    }
    
    // MARK: - Logo Customizations
    
    func setLogo(image: UIImage?, frame: CGRect) {
        model.logoImage = image
        model.logoFrame = frame
    }
    
    func clearLogo() {
        model.logoImage = nil
        model.logoFrame = .zero
    }
    
    func setLogoShape(_ shape: LogoShape) {
        model.logoShape = shape
    }
    
    func setLogoPositionRatio(_ ratio: CGPoint) {
        model.logoPositionRatio = ratio
    }
    
    func setCoverImage(_ image: UIImage?) {
        model.coverImage = image
    }
    
    func setCustomBorderWidth(_ width: CGFloat?) {
        model.customBorderWidth = width
    }
    
    func setCustomCornerRadius(_ radius: CGFloat?) {
        model.customCornerRadius = radius
    }
    
    // MARK: - Rotate & Crop Editing
    
    func rotateVideoClockwise() {
        model.rotationDegrees = (model.rotationDegrees + 90) % 360
    }
    
    func setCropRect(_ rect: CGRect) {
        model.cropRect = rect
    }
    
    // MARK: - Headline Editing
    
    func setHeadline(text: String?, font: UIFont = .systemFont(ofSize: 17, weight: .bold)) {
        if let text = text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            model.headlineText = text
            model.headlineFont = font
        } else {
            model.headlineText = nil
        }
    }
    
    func clearHeadline() {
        model.headlineText = nil
    }
    
    // MARK: - Navigation Steps
    
    func nextStep() -> Bool {
        if currentStepIndex < totalSteps - 1 {
            currentStepIndex += 1
            return true
        }
        return false
    }
    
    func previousStep() -> Bool {
        if currentStepIndex > 0 {
            currentStepIndex -= 1
            return true
        }
        return false
    }
    
    func setCustomFrameColor(_ color: UIColor?) {
        model.customFrameColor = color
    }
    
    // MARK: - Export / Process Video
    
    func processVideo(previewBounds: CGRect, completion: @escaping (URL?) -> Void) {
        VideoExporter.shared.export(
            videoURL: model.videoURL,
            frameTemplate: model.selectedFrame,
            customFrameColor: model.customFrameColor,
            customBorderWidth: model.customBorderWidth,
            customCornerRadius: model.customCornerRadius,
            aspectRatio: model.aspectRatio,
            icon: model.logoImage,
            iconFrame: model.logoFrame,
            logoShape: model.logoShape,
            logoPositionRatio: model.logoPositionRatio,
            rotationDegrees: model.rotationDegrees,
            cropRect: model.cropRect,
            headlineText: model.headlineText,
            headlineFont: model.headlineFont,
            trimStartTime: model.trimStartTime,
            trimEndTime: model.trimEndTime,
            muteOriginalAudio: model.muteOriginalAudio,
            replacementAudioURL: model.replacementAudioURL,
            replacementAudioVolume: model.replacementAudioVolume,
            previewBounds: previewBounds,
            completion: completion
        )
    }
}
