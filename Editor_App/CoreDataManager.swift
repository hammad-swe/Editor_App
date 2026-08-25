//
//  CoreDataManager.swift
//  Editor_App
//
//  Created by Antigravity on 19/08/2026.
//

import UIKit
import CoreData
import AVFoundation

struct EditedVideoProject: Codable {
    let id: String
    let title: String
    let relativeVideoPath: String
    let relativeThumbnailPath: String
    let logoName: String?
    let headlineText: String?
    let createdAt: Date
    
    var fullVideoURL: URL? {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(relativeVideoPath)
    }
    
    var thumbnailImage: UIImage? {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let path = documents.appendingPathComponent(relativeThumbnailPath).path
        return UIImage(contentsOfFile: path)
    }
}

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    private var projectsDirectory: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = documents.appendingPathComponent("SavedProjects", isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }
    
    private var metadataFileURL: URL {
        return projectsDirectory.appendingPathComponent("projects_metadata.json")
    }
    
    // MARK: - Save Project
    
    func saveProject(
        exportedVideoURL: URL,
        title: String? = nil,
        logoName: String? = nil,
        headlineText: String? = nil,
        coverImage: UIImage? = nil,
        completion: @escaping (Bool) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let projectId = UUID().uuidString
            let videoFileName = "\(projectId).mov"
            let thumbFileName = "\(projectId).jpg"
            
            let destVideoURL = self.projectsDirectory.appendingPathComponent(videoFileName)
            let destThumbURL = self.projectsDirectory.appendingPathComponent(thumbFileName)
            
            // 1. Copy video file
            do {
                if FileManager.default.fileExists(atPath: destVideoURL.path) {
                    try FileManager.default.removeItem(at: destVideoURL)
                }
                try FileManager.default.copyItem(at: exportedVideoURL, to: destVideoURL)
            } catch {
                print("Failed to save project video: \(error)")
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            // 2. Generate and save thumbnail image (use coverImage if provided)
            let thumbnail = coverImage ?? self.generateThumbnail(for: destVideoURL)
            if let thumbnail = thumbnail, let jpegData = thumbnail.jpegData(compressionQuality: 0.8) {
                try? jpegData.write(to: destThumbURL)
            }
            
            // 3. Create metadata item
            let relativeVideoPath = "SavedProjects/\(videoFileName)"
            let relativeThumbPath = "SavedProjects/\(thumbFileName)"
            let projectTitle = title ?? headlineText ?? "Project \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short))"
            
            let project = EditedVideoProject(
                id: projectId,
                title: projectTitle,
                relativeVideoPath: relativeVideoPath,
                relativeThumbnailPath: relativeThumbPath,
                logoName: logoName,
                headlineText: headlineText,
                createdAt: Date()
            )
            
            var currentProjects = self.fetchAllProjects()
            currentProjects.insert(project, at: 0)
            
            self.saveProjectsToStorage(currentProjects)
            DispatchQueue.main.async { completion(true) }
        }
    }
    
    // MARK: - Fetch Projects
    
    func fetchAllProjects() -> [EditedVideoProject] {
        guard FileManager.default.fileExists(atPath: metadataFileURL.path),
              let data = try? Data(contentsOf: metadataFileURL),
              let projects = try? JSONDecoder().decode([EditedVideoProject].self, from: data) else {
            return []
        }
        return projects
    }
    
    // MARK: - Delete Project
    
    func deleteProject(_ project: EditedVideoProject) {
        var projects = fetchAllProjects()
        projects.removeAll { $0.id == project.id }
        saveProjectsToStorage(projects)
        
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let videoURL = documents.appendingPathComponent(project.relativeVideoPath)
        let thumbURL = documents.appendingPathComponent(project.relativeThumbnailPath)
        
        try? FileManager.default.removeItem(at: videoURL)
        try? FileManager.default.removeItem(at: thumbURL)
    }
    
    // MARK: - Clear All Cache
    
    func clearCache() {
        let tempDir = FileManager.default.temporaryDirectory
        if let files = try? FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil) {
            for file in files {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func saveProjectsToStorage(_ projects: [EditedVideoProject]) {
        if let data = try? JSONEncoder().encode(projects) {
            try? data.write(to: metadataFileURL)
        }
    }
    
    private func generateThumbnail(for url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            return nil
        }
    }
}
