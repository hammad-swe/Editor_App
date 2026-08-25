//
//  MyProjectsViewController.swift
//  Editor_App
//
//  Created by Antigravity on 19/08/2026.
//

import UIKit
import AVKit

class MyProjectsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!

    private var projects: [EditedVideoProject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Saved Projects"
        setupTableView()
        loadProjects()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        loadProjects()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            UINib(nibName: "ProjectCell", bundle: nil),
            forCellReuseIdentifier: "ProjectCell"
        )
        tableView.tableFooterView = UIView()
    }

    private func loadProjects() {
        projects = CoreDataManager.shared.fetchAllProjects()
        emptyLabel.isHidden = !projects.isEmpty
        tableView.reloadData()
    }
}

extension MyProjectsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath) as! ProjectCell
        let project = projects[indexPath.row]
        cell.configure(with: project)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let project = projects[indexPath.row]
        guard let videoURL = project.fullVideoURL else {
            let alert = UIAlertController(title: "Error", message: "Video file not found.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let project = projects[indexPath.row]
            CoreDataManager.shared.deleteProject(project)
            projects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            emptyLabel.isHidden = !projects.isEmpty
        }
    }
}
