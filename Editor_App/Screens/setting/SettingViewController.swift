//
//  SettingViewController.swift
//  Editor_App
//
//  Created by Hammad Ali on 17/08/2026.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var projectCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        setupTableView()
        setupHeaderAndFooter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        projectCount = CoreDataManager.shared.fetchAllProjects().count
        tableView.reloadData()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            BeautifulSettingCell.self,
            forCellReuseIdentifier: BeautifulSettingCell.reuseIdentifier
        )
        tableView.backgroundColor = .systemGroupedBackground
        tableView.rowHeight = 62
    }
    
    private func setupHeaderAndFooter() {
        // Hero Header View
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 130))
        
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1.0
        card.layer.borderColor = UIColor.separator.cgColor
        headerView.addSubview(card)
        
        let avatarBg = UIView()
        avatarBg.translatesAutoresizingMaskIntoConstraints = false
        avatarBg.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
        avatarBg.layer.cornerRadius = 24
        avatarBg.clipsToBounds = true
        card.addSubview(avatarBg)
        
        let avatarIcon = UIImageView(image: UIImage(systemName: "film.stack.fill"))
        avatarIcon.translatesAutoresizingMaskIntoConstraints = false
        avatarIcon.tintColor = .systemBlue
        avatarIcon.contentMode = .scaleAspectFit
        avatarBg.addSubview(avatarIcon)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Editor Studio Pro"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .label
        card.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Version 1.0.0 • On-Device Processing"
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        card.addSubview(subtitleLabel)
        
        let privacyBadge = UILabel()
        privacyBadge.translatesAutoresizingMaskIntoConstraints = false
        privacyBadge.text = " ● 100% Private "
        privacyBadge.font = .systemFont(ofSize: 11, weight: .semibold)
        privacyBadge.textColor = .systemGreen
        privacyBadge.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        privacyBadge.layer.cornerRadius = 6
        privacyBadge.clipsToBounds = true
        card.addSubview(privacyBadge)
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            card.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12),
            
            avatarBg.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            avatarBg.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatarBg.widthAnchor.constraint(equalToConstant: 48),
            avatarBg.heightAnchor.constraint(equalToConstant: 48),
            
            avatarIcon.centerXAnchor.constraint(equalTo: avatarBg.centerXAnchor),
            avatarIcon.centerYAnchor.constraint(equalTo: avatarBg.centerYAnchor),
            avatarIcon.widthAnchor.constraint(equalToConstant: 24),
            avatarIcon.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: avatarBg.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: privacyBadge.leadingAnchor, constant: -8),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: avatarBg.trailingAnchor, constant: 14),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: privacyBadge.leadingAnchor, constant: -8),
            
            privacyBadge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            privacyBadge.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            privacyBadge.heightAnchor.constraint(equalToConstant: 22)
        ])
        
        tableView.tableHeaderView = headerView
        
        // Footer View
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
        let footerLabel = UILabel()
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        footerLabel.text = "Crafted with ❤️ for Video Creators\n© 2026 Editor App • All Rights Reserved"
        footerLabel.font = .systemFont(ofSize: 11, weight: .regular)
        footerLabel.textColor = .tertiaryLabel
        footerLabel.textAlignment = .center
        footerLabel.numberOfLines = 2
        footerView.addSubview(footerLabel)
        
        NSLayoutConstraint.activate([
            footerLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            footerLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        
        tableView.tableFooterView = footerView
    }
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 // My Projects
        case 1: return 1 // Clear Cache
        case 2: return 3 // App Version, Rate App, Privacy Policy
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "PROJECTS & STORAGE"
        case 1: return "MEMORY & PERFORMANCE"
        case 2: return "ABOUT EDITOR APP"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: BeautifulSettingCell.reuseIdentifier,
            for: indexPath
        ) as! BeautifulSettingCell

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let countText = projectCount == 1 ? "1 project stored" : "\(projectCount) projects stored"
            cell.configure(
                title: "My Saved Projects",
                subtitle: countText,
                value: nil,
                systemIcon: "folder.fill",
                badgeColor: .systemBlue,
                showDisclosure: true
            )
            
        case (1, 0):
            cell.configure(
                title: "Clear Cache & Temp Files",
                subtitle: "Free up temporary export storage",
                value: nil,
                systemIcon: "trash.fill",
                badgeColor: .systemRed,
                showDisclosure: false
            )
            
        case (2, 0):
            cell.configure(
                title: "App Version",
                subtitle: "Latest release build",
                value: "1.0.0",
                systemIcon: "info.circle.fill",
                badgeColor: .systemGray,
                showDisclosure: false
            )
            
        case (2, 1):
            cell.configure(
                title: "Rate Editor App",
                subtitle: "Support us on the App Store",
                value: nil,
                systemIcon: "star.fill",
                badgeColor: .systemOrange,
                showDisclosure: true
            )
            
        case (2, 2):
            cell.configure(
                title: "Privacy Policy",
                subtitle: "On-device processing & local storage",
                value: nil,
                systemIcon: "shield.fill",
                badgeColor: .systemGreen,
                showDisclosure: true
            )
            
        default:
            break
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let projectsVC = MyProjectsViewController(nibName: "MyProjectsViewController", bundle: nil)
            navigationController?.pushViewController(projectsVC, animated: true)
            
        case (1, 0):
            CoreDataManager.shared.clearCache()
            let alert = UIAlertController(
                title: "Cache Cleared",
                message: "Temporary export files and render cache have been removed successfully.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            
        case (2, 1):
            let alert = UIAlertController(
                title: "Rate Editor App",
                message: "Thank you for using Editor App! We appreciate your support and rating on the App Store.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            
        case (2, 2):
            let alert = UIAlertController(
                title: "Privacy Policy",
                message: "Your privacy is our top priority. All photos and videos remain 100% local on your device. We do not track, collect, or upload your media to any server.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            
        default:
            break
        }
    }
}
