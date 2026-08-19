//
//  SettingViewController.swift
//  Editor_App
//
//  Created by Hammad Ali on 17/08/2026.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        setupTableView()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
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
        case 0: return "Projects & Storage"
        case 1: return "Cache Management"
        case 2: return "About Editor App"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "SettingCell")
        cell.accessoryType = .disclosureIndicator

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.textLabel?.text = "My Saved Projects"
            cell.imageView?.image = UIImage(systemName: "folder.fill")
            cell.imageView?.tintColor = .systemBlue
        case (1, 0):
            cell.textLabel?.text = "Clear Cache & Temp Exports"
            cell.imageView?.image = UIImage(systemName: "trash.fill")
            cell.imageView?.tintColor = .systemRed
            cell.accessoryType = .none
        case (2, 0):
            cell.textLabel?.text = "App Version"
            cell.detailTextLabel?.text = "1.0.0"
            cell.imageView?.image = UIImage(systemName: "info.circle.fill")
            cell.imageView?.tintColor = .systemGray
            cell.accessoryType = .none
        case (2, 1):
            cell.textLabel?.text = "Rate App"
            cell.imageView?.image = UIImage(systemName: "star.fill")
            cell.imageView?.tintColor = .systemYellow
        case (2, 2):
            cell.textLabel?.text = "Privacy Policy"
            cell.imageView?.image = UIImage(systemName: "hand.raised.fill")
            cell.imageView?.tintColor = .systemGreen
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
            let alert = UIAlertController(title: "Cache Cleared", message: "Temporary export files have been removed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        case (2, 1):
            let alert = UIAlertController(title: "Rate Us", message: "Thank you for using Editor App! Rate us on the App Store.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        case (2, 2):
            let alert = UIAlertController(title: "Privacy Policy", message: "Your media remains entirely local on your device. We do not collect or upload your photos or videos.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        default:
            break
        }
    }
}
