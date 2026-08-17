//
//  MainViewController.swift
//  Editor_App
//
//  Created by Hammad Ali on 17/08/2026.
//

import UIKit
import PhotosUI
import Photos

class MainViewController: UIViewController {
    
    
    
    @IBOutlet weak var cardView: UIStackView!
    @IBOutlet weak var videoView: UIStackView!
    @IBOutlet weak var photoView: UIStackView!
    @IBOutlet weak var CollegeView: UIStackView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setupCardTapGestures()
        
    }
    
    private func setUpUI(){
        
        title =  "Editor"
        navigationItem.hidesBackButton = true
        let buttonImage = UIImage(systemName: "gear")
        
        let settingButton = UIBarButtonItem(
            image: buttonImage,
                    style: .plain,
                target: self,
                action: #selector(rightButtonTapped)
            )
        settingButton.tintColor =  .systemFill
        navigationItem.rightBarButtonItem = settingButton
        
        
        cardView.layer.cornerRadius = 10
        
    }

    @objc func rightButtonTapped() {
        let vc =  SettingViewController(nibName: " SettingViewController", bundle: nil)
      self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupCardTapGestures() {
            let photoTap = UITapGestureRecognizer(target: self, action: #selector(photoCardTapped))
            photoView.addGestureRecognizer(photoTap)
            photoView.isUserInteractionEnabled = true
            
            let videoTap = UITapGestureRecognizer(target: self, action: #selector(videoCardTapped))
            videoView.addGestureRecognizer(videoTap)
            videoView.isUserInteractionEnabled = true
            
            let collegeTap = UITapGestureRecognizer(target: self, action: #selector(collegeCardTapped))
            CollegeView.addGestureRecognizer(collegeTap)
            CollegeView.isUserInteractionEnabled = true
        }
        
        @objc private func photoCardTapped() {
            openGallery(filter: .photo)
        }
        
        @objc private func videoCardTapped() {
            openGallery(filter: .video)
        }
        
        @objc private func collegeCardTapped() {
            // openGallery(filter: .??) — what should this filter to?
        }
        
    private func openGallery(filter: GalleryFilter) {
        GalleryManager.shared.requestAccess { [weak self] granted in
            guard let self = self else { return }
            if granted {
                let vc = GalleryViewController()
                vc.initialFilter = filter
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.showPermissionDeniedAlert()
            }
        }
    }
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Photo Access Needed",
            message: "Please enable photo library access in Settings to view your photos and videos.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    }
    
