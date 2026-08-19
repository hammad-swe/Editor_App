//
//  TemplateManager.swift
//  Editor_App
//
//  Created by Antigravity on 19/08/2026.
//

import UIKit

struct LogoTemplate {
    let id: String
    let name: String
    let image: UIImage
    let isBuiltIn: Bool
}

struct HeadlineTemplate {
    let id: String
    let name: String
    let text: String
    let font: UIFont
    let textColor: UIColor
    let isBuiltIn: Bool
}

final class TemplateManager {
    
    static let shared = TemplateManager()
    private init() {}
    
    // MARK: - Logo Templates
    
    func logoTemplates() -> [LogoTemplate] {
        var templates: [LogoTemplate] = []
        
        // System / Built-in templates using SF Symbols & default assets
        if let shapes1Image = UIImage(named: "shapes1") {
            templates.append(LogoTemplate(id: "shapes1", name: "Default Shape", image: shapes1Image, isBuiltIn: true))
        }
        if let badgeImage = UIImage(systemName: "seal.fill")?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal) {
            templates.append(LogoTemplate(id: "badge", name: "Quality Badge", image: badgeImage, isBuiltIn: true))
        }
        if let starImage = UIImage(systemName: "star.circle.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal) {
            templates.append(LogoTemplate(id: "star", name: "Star Stamp", image: starImage, isBuiltIn: true))
        }
        if let checkImage = UIImage(systemName: "checkmark.seal.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal) {
            templates.append(LogoTemplate(id: "verified", name: "Verified Stamp", image: checkImage, isBuiltIn: true))
        }
        if let playImage = UIImage(systemName: "play.circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal) {
            templates.append(LogoTemplate(id: "play_badge", name: "Play Watermark", image: playImage, isBuiltIn: true))
        }
        
        return templates
    }
    
    // MARK: - Headline Templates
    
    func headlineTemplates() -> [HeadlineTemplate] {
        return [
            HeadlineTemplate(
                id: "welcome",
                name: "Welcome Headline",
                text: "Welcome to New Video!",
                font: .systemFont(ofSize: 18, weight: .bold),
                textColor: .white,
                isBuiltIn: true
            ),
            HeadlineTemplate(
                id: "breaking",
                name: "Breaking News",
                text: "BREAKING NEWS • LIVE UPDATE",
                font: .systemFont(ofSize: 18, weight: .black),
                textColor: .systemRed,
                isBuiltIn: true
            ),
            HeadlineTemplate(
                id: "subscribe",
                name: "Subscribe Callout",
                text: "Like & Subscribe for More Content!",
                font: .systemFont(ofSize: 17, weight: .bold),
                textColor: .systemYellow,
                isBuiltIn: true
            ),
            HeadlineTemplate(
                id: "follow",
                name: "Social Follow",
                text: "Follow us @EditorApp for daily clips",
                font: .systemFont(ofSize: 16, weight: .semibold),
                textColor: .systemCyan,
                isBuiltIn: true
            ),
            HeadlineTemplate(
                id: "copyright",
                name: "Copyright Notice",
                text: "© 2026 Editor App. All Rights Reserved.",
                font: .systemFont(ofSize: 15, weight: .regular),
                textColor: .lightGray,
                isBuiltIn: true
            )
        ]
    }
}
