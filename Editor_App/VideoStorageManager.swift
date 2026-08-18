//
//  VideoStorageManager.swift
//  Editor_App
//
//  Created by Hammad Ali on 18/08/2026.
//

import Photos
import AVFoundation

final class VideoStorageManager {
    
    static let shared = VideoStorageManager()
    private init() {}
    
    private var videosDirectory: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = documents.appendingPathComponent("EditorVideos", isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }
    
    /// Copies the video backing a PHAsset into local app storage and returns the file URL.
    func saveVideo(from asset: PHAsset, completion: @escaping (URL?) -> Void) {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { [weak self] avAsset, _, _ in
            guard let self = self, let urlAsset = avAsset as? AVURLAsset else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            let fileName = UUID().uuidString + ".mov"
            let destinationURL = self.videosDirectory.appendingPathComponent(fileName)
            
            do {
                try FileManager.default.copyItem(at: urlAsset.url, to: destinationURL)
                DispatchQueue.main.async { completion(destinationURL) }
            } catch {
                print("VideoStorageManager copy failed: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
    
    /// Deletes a previously saved local video.
    func deleteVideo(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
    
    /// Lists all locally saved videos (useful for a "My Projects" screen later).
    func allSavedVideos() -> [URL] {
        (try? FileManager.default.contentsOfDirectory(at: videosDirectory, includingPropertiesForKeys: nil)) ?? []
    }
}
