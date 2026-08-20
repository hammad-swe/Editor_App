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
    let totalSteps: Int = 3
    
    var isFirstStep: Bool { currentStepIndex == 0 }
    var isLastStep: Bool { currentStepIndex == totalSteps - 1 }
    
    init(videoURL: URL) {
        self.model = VideoEditingModel(videoURL: videoURL)
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
    
    // MARK: - Logo Editing
    
    func setLogo(image: UIImage?, frame: CGRect) {
        model.logoImage = image
        model.logoFrame = frame
    }
    
    func clearLogo() {
        model.logoImage = nil
        model.logoFrame = .zero
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
    
    // MARK: - Export / Process Video
    
    func processVideo(previewBounds: CGRect, completion: @escaping (URL?) -> Void) {
        VideoExporter.shared.export(
            videoURL: model.videoURL,
            frameTemplate: model.selectedFrame,
            aspectRatio: model.aspectRatio,
            icon: model.logoImage,
            iconFrame: model.logoFrame,
            headlineText: model.headlineText,
            headlineFont: model.headlineFont,
            previewBounds: previewBounds,
            completion: completion
        )
    }
}
