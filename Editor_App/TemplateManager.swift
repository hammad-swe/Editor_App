//
//  TemplateManager.swift
//  Editor_App
//
//  Created by Antigravity on 19/08/2026.
//

import UIKit

enum VideoAspectRatio: String, CaseIterable, Codable {
    case original = "Original"
    case ratio16_9 = "16:9"
    case ratio9_16 = "9:16"
    case ratio1_1 = "1:1"
    case ratio4_5 = "4:5"
    
    var ratioValue: CGFloat? {
        switch self {
        case .original: return nil
        case .ratio16_9: return 16.0 / 9.0
        case .ratio9_16: return 9.0 / 16.0
        case .ratio1_1: return 1.0
        case .ratio4_5: return 4.0 / 5.0
        }
    }
}

enum HeadlineAnimationStyle: String, Codable {
    case slidingTicker = "Sliding Ticker"
    case staticCentered = "Static Banner"
    case pulsingBadge = "Live Pulsing"
}

enum FrameStyle: String, Codable {
    case none
    case classic
    case cinematic
    case rounded
    case polaroid
    case neonGlow
    case vintage
    case newsBroadcast
    case sportsBroadcast
    case podcastShow
    case minimal
    case gradient
    case filmStrip
    case glitch
    case splitDual
}

struct FrameTemplate: Equatable {
    let id: String
    let name: String
    let style: FrameStyle
    let borderColor: UIColor
    let borderWidth: CGFloat
    let cornerRadius: CGFloat
    let defaultAspect: VideoAspectRatio
    let defaultLogo: UIImage?
    let defaultHeadline: String?
    let headlineStyle: HeadlineAnimationStyle
    let isBuiltIn: Bool
    
    static func == (lhs: FrameTemplate, rhs: FrameTemplate) -> Bool {
        return lhs.id == rhs.id
    }
}

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
    
    // MARK: - Frame Templates
    
    func allTemplates() -> [FrameTemplate] {
        let builtIn = frameTemplates()
        let customSaved = CustomTemplateStorage.shared.fetchAllTemplates().map {
            CustomTemplateStorage.shared.convertToFrameTemplate($0)
        }
        return builtIn + customSaved
    }
    
    func frameTemplates() -> [FrameTemplate] {
        let playBadge = UIImage(systemName: "play.circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        let starBadge = UIImage(systemName: "star.circle.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        let sealBadge = UIImage(systemName: "seal.fill")?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal)
        let checkBadge = UIImage(systemName: "checkmark.seal.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        let tvBadge = UIImage(systemName: "tv.fill")?.withTintColor(.systemCyan, renderingMode: .alwaysOriginal)
        let liveBadge = UIImage(systemName: "record.circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        let trophyBadge = UIImage(systemName: "trophy.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        let flameBadge = UIImage(systemName: "flame.fill")?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal)
        let filmBadge = UIImage(systemName: "film.stack.fill")?.withTintColor(.systemIndigo, renderingMode: .alwaysOriginal)
        let sparkleBadge = UIImage(systemName: "sparkles")?.withTintColor(.systemPink, renderingMode: .alwaysOriginal)
        let shapes1Img = UIImage(named: "shapes1")
        
        return [
            FrameTemplate(
                id: "original",
                name: "Original",
                style: .none,
                borderColor: .clear,
                borderWidth: 0,
                cornerRadius: 0,
                defaultAspect: .original,
                defaultLogo: nil,
                defaultHeadline: nil,
                headlineStyle: .staticCentered,
                isBuiltIn: true
            ),
            FrameTemplate(
                id: "news_broadcast",
                name: "News Ticker",
                style: .newsBroadcast,
                borderColor: .systemRed,
                borderWidth: 8,
                cornerRadius: 0,
                defaultAspect: .ratio16_9,
                defaultLogo: liveBadge,
                defaultHeadline: "BREAKING NEWS • LIVE COVERAGE ON AIR • CONTINUOUS TICKER UPDATE",
                headlineStyle: .slidingTicker,
                isBuiltIn: true
            ),
            FrameTemplate(
                id: "sports_broadcast",
                name: "Sports Extra",
                style: .sportsBroadcast,
                borderColor: UIColor(red: 0.1, green: 0.2, blue: 0.5, alpha: 1.0),
                borderWidth: 10,
                cornerRadius: 0,
                defaultAspect: .ratio16_9,
                defaultLogo: trophyBadge,
                defaultHeadline: "SPORTS HIGHLIGHTS • MATCH DAY RESULTS • CHAMPIONSHIP FINALS",
                headlineStyle: .slidingTicker,
                isBuiltIn: true
            ),
            FrameTemplate(
                id: "viral_reel",
                name: "Viral Reel",
                style: .neonGlow,
                borderColor: UIColor(red: 0.0, green: 0.88, blue: 1.0, alpha: 1.0),
                borderWidth: 8,
                cornerRadius: 16,
                defaultAspect: .ratio9_16,
                defaultLogo: flameBadge,
                defaultHeadline: "🔥 TRENDING NOW • WATCH TILL THE END • SHARE WITH FRIENDS",
                headlineStyle: .slidingTicker,
                isBuiltIn: true
            ),
            FrameTemplate(
                id: "podcast_show",
                name: "Podcast Talk",
                style: .podcastShow,
                borderColor: UIColor(red: 0.4, green: 0.1, blue: 0.6, alpha: 1.0),
                borderWidth: 10,
                cornerRadius: 12,
                defaultAspect: .ratio9_16,
                defaultLogo: checkBadge,
                defaultHeadline: "EXCLUSIVE TALK PODCAST • SPECIAL GUEST",
                headlineStyle: .staticCentered,
                isBuiltIn: true
            ),
            FrameTemplate(
                id: "cinematic",
                name: "Cinematic 16:9",
                style: .cinematic,
                borderColor: .black,
                borderWidth: 28,
                cornerRadius: 0,
                defaultAspect: .ratio16_9,
                defaultLogo: tvBadge,
                defaultHeadline: "CINEMATIC PRESENTATION • DIRECTORS CUT",
                headlineStyle: .staticCentered,
                isBuiltIn: true
            ),
            FrameTemplate(
                id: "classic_white",
                name: "Classic White",
                style: .classic,
                borderColor: .white,
                borderWidth: 12,
                cornerRadius: 0,
                defaultAspect: .ratio1_1,
                defaultLogo: shapes1Img,
                defaultHeadline: "SPECIAL EDITION • EXCLUSIVE STORY",
                headlineStyle: .staticCentered,
                isBuiltIn: true
            ),
            FrameTemplate(
                id: "minimal_dark",
                name: "Minimal Dark",
                style: .minimal,
                borderColor: UIColor.darkGray,
                borderWidth: 3,
                cornerRadius: 8,
                defaultAspect: .ratio1_1,
                defaultLogo: starBadge,
                defaultHeadline: "MINIMAL DESIGN • CLEAN STYLE",
                headlineStyle: .staticCentered,
                isBuiltIn: true
            ),
            FrameTemplate(
                id: "gradient_wave",
                name: "Gradient Wave",
                style: .gradient,
                borderColor: .systemPurple,
                borderWidth: 8,
                cornerRadius: 14,
                defaultAspect: .ratio9_16,
                defaultLogo: sparkleBadge,
                defaultHeadline: "VIBRANT GRADIENT • MODERN WAVE",
                headlineStyle: .slidingTicker,
                isBuiltIn: true
            ),
            FrameTemplate(
                id: "film_strip",
                name: "Film Strip",
                style: .filmStrip,
                borderColor: .black,
                borderWidth: 14,
                cornerRadius: 0,
                defaultAspect: .ratio16_9,
                defaultLogo: filmBadge,
                defaultHeadline: "VINTAGE MOVIE • 35MM REEL",
                headlineStyle: .staticCentered,
                isBuiltIn: true
            ),
            FrameTemplate(
                id: "glitch_art",
                name: "Glitch Art",
                style: .glitch,
                borderColor: .systemPink,
                borderWidth: 6,
                cornerRadius: 4,
                defaultAspect: .ratio9_16,
                defaultLogo: flameBadge,
                defaultHeadline: "CYBER GLITCH • RETRO WAVE",
                headlineStyle: .slidingTicker,
                isBuiltIn: true
            ),
            FrameTemplate(
                id: "split_dual",
                name: "Split Dual",
                style: .splitDual,
                borderColor: .systemTeal,
                borderWidth: 6,
                cornerRadius: 0,
                defaultAspect: .ratio16_9,
                defaultLogo: sealBadge,
                defaultHeadline: "DUAL VIEW • SPLIT HIGHLIGHTS",
                headlineStyle: .staticCentered,
                isBuiltIn: true
            )
        ]
    }
    
    // MARK: - Logo Templates
    
    func logoTemplates() -> [LogoTemplate] {
        var templates: [LogoTemplate] = []
        
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
        if let tvImage = UIImage(systemName: "tv.fill")?.withTintColor(.systemCyan, renderingMode: .alwaysOriginal) {
            templates.append(LogoTemplate(id: "broadcast_hd", name: "Broadcast HD", image: tvImage, isBuiltIn: true))
        }
        if let liveImage = UIImage(systemName: "record.circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal) {
            templates.append(LogoTemplate(id: "live_badge", name: "Live Badge", image: liveImage, isBuiltIn: true))
        }
        if let trophyImage = UIImage(systemName: "trophy.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal) {
            templates.append(LogoTemplate(id: "trophy", name: "Sports Trophy", image: trophyImage, isBuiltIn: true))
        }
        if let micImage = UIImage(systemName: "mic.fill")?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal) {
            templates.append(LogoTemplate(id: "mic", name: "Podcast Mic", image: micImage, isBuiltIn: true))
        }
        if let flameImage = UIImage(systemName: "flame.fill")?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal) {
            templates.append(LogoTemplate(id: "flame", name: "Flame Trending", image: flameImage, isBuiltIn: true))
        }
        if let musicImage = UIImage(systemName: "music.note.list")?.withTintColor(.systemPink, renderingMode: .alwaysOriginal) {
            templates.append(LogoTemplate(id: "music", name: "Music Note", image: musicImage, isBuiltIn: true))
        }
        if let filmImage = UIImage(systemName: "film.stack.fill")?.withTintColor(.systemIndigo, renderingMode: .alwaysOriginal) {
            templates.append(LogoTemplate(id: "film", name: "Film Reel", image: filmImage, isBuiltIn: true))
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
                text: "BREAKING NEWS • LIVE UPDATE ON AIR",
                font: .systemFont(ofSize: 18, weight: .black),
                textColor: .systemRed,
                isBuiltIn: true
            ),
            HeadlineTemplate(
                id: "sports",
                name: "Sports Highlights",
                text: "SPORTS EXTRA • CHAMPIONSHIP HIGHLIGHTS & SCORES",
                font: .systemFont(ofSize: 18, weight: .heavy),
                textColor: .systemYellow,
                isBuiltIn: true
            ),
            HeadlineTemplate(
                id: "podcast",
                name: "Podcast Exclusive",
                text: "EXCLUSIVE TALK PODCAST • EPISODE #42 LIVE",
                font: .systemFont(ofSize: 17, weight: .bold),
                textColor: .systemPurple,
                isBuiltIn: true
            ),
            HeadlineTemplate(
                id: "trending",
                name: "Trending Reel",
                text: "🔥 TRENDING NOW • WATCH TILL THE END!",
                font: .systemFont(ofSize: 18, weight: .bold),
                textColor: .systemOrange,
                isBuiltIn: true
            ),
            HeadlineTemplate(
                id: "special_report",
                name: "Special Report",
                text: "🔴 SPECIAL REPORT • LIVE FIELD COVERAGE",
                font: .systemFont(ofSize: 17, weight: .black),
                textColor: .systemRed,
                isBuiltIn: true
            ),
            HeadlineTemplate(
                id: "music_beats",
                name: "Music Audio",
                text: "🎵 NOW PLAYING • OFFICIAL AUDIO RELEASE",
                font: .systemFont(ofSize: 17, weight: .bold),
                textColor: .systemPink,
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
