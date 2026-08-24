//
//  CustomTemplateStorage.swift
//  Editor_App
//
//  Created by Antigravity on 24/08/2026.
//

import UIKit

struct SavedCustomTemplate: Codable {
    let id: String
    let name: String
    let styleRaw: String
    let borderColorHex: String
    let borderWidth: CGFloat
    let cornerRadius: CGFloat
    let defaultAspectRaw: String
    let logoShapeRaw: String
    let logoPositionX: CGFloat
    let logoPositionY: CGFloat
    let headlineText: String?
    let createdAt: Date
}

final class CustomTemplateStorage {
    static let shared = CustomTemplateStorage()
    private init() {}
    
    private var customTemplatesDirectory: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = documents.appendingPathComponent("CustomTemplates", isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }
    
    private var metadataFileURL: URL {
        return customTemplatesDirectory.appendingPathComponent("custom_templates.json")
    }
    
    func fetchAllTemplates() -> [SavedCustomTemplate] {
        guard FileManager.default.fileExists(atPath: metadataFileURL.path),
              let data = try? Data(contentsOf: metadataFileURL),
              let templates = try? JSONDecoder().decode([SavedCustomTemplate].self, from: data) else {
            return []
        }
        return templates
    }
    
    func saveTemplate(_ template: SavedCustomTemplate) {
        var existing = fetchAllTemplates()
        existing.append(template)
        if let data = try? JSONEncoder().encode(existing) {
            try? data.write(to: metadataFileURL)
        }
    }
    
    func deleteTemplate(id: String) {
        var existing = fetchAllTemplates()
        existing.removeAll { $0.id == id }
        if let data = try? JSONEncoder().encode(existing) {
            try? data.write(to: metadataFileURL)
        }
    }
    
    func convertToFrameTemplate(_ saved: SavedCustomTemplate) -> FrameTemplate {
        let style = FrameStyle(rawValue: saved.styleRaw) ?? .classic
        let color = UIColor(hex: saved.borderColorHex) ?? .systemBlue
        let aspect = VideoAspectRatio(rawValue: saved.defaultAspectRaw) ?? .original
        
        let logoImage = UIImage(systemName: "sparkles")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        
        return FrameTemplate(
            id: saved.id,
            name: saved.name,
            style: style,
            borderColor: color,
            borderWidth: saved.borderWidth,
            cornerRadius: saved.cornerRadius,
            defaultAspect: aspect,
            defaultLogo: logoImage,
            defaultHeadline: saved.headlineText ?? "CUSTOM TEMPLATE",
            headlineStyle: .staticCentered,
            isBuiltIn: false
        )
    }
}

// MARK: - UIColor Hex Extension
extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    func toHex() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06x", rgb)
    }
}
