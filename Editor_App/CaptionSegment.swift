//
//  CaptionSegment.swift
//  Editor_App
//
//  Created by Antigravity on 25/08/2026.
//

import UIKit

struct CaptionSegment: Codable, Equatable {
    var startTime: Double
    var duration: Double
    var text: String
    var originalText: String?
}

enum CaptionStyle: String, CaseIterable, Codable {
    case darkBanner = "Dark Banner"
    case yellowNeon = "Yellow Neon"
    case minimalWhite = "Minimal White"
    case redAlert = "Red Alert"
    
    var backgroundColor: UIColor {
        switch self {
        case .darkBanner: return UIColor.black.withAlphaComponent(0.8)
        case .yellowNeon: return UIColor.systemYellow.withAlphaComponent(0.95)
        case .minimalWhite: return UIColor.white.withAlphaComponent(0.9)
        case .redAlert: return UIColor.systemRed.withAlphaComponent(0.9)
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .darkBanner: return .white
        case .yellowNeon: return .black
        case .minimalWhite: return .black
        case .redAlert: return .white
        }
    }
}
