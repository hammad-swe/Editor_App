//
//  AddTextStepViewController.swift
//  Editor_App
//
//  Created by Antigravity on 19/08/2026.
//

import UIKit

class AddTextStepViewController: UIViewController, EditorStepViewController {

    weak var stepDelegate: EditorStepDelegate?
    var viewModel: VideoEditingViewModel!

    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var templateTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!

    private var templates: [HeadlineTemplate] = []
    private var selectedTemplateIndex: Int?
    private var activeFont: UIFont = .systemFont(ofSize: 18, weight: .bold)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Add Text"

        templates = TemplateManager.shared.headlineTemplates()
        setupUI()
        setupTableView()
        restoreExistingData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        restoreExistingData()
    }

    private func setupUI() {
        stepLabel.text = "Step 6 of \(viewModel?.totalSteps ?? 6): Add Headline Text"

        textField.delegate = self

        backButton.layer.cornerRadius = 10
        skipButton.layer.cornerRadius = 10
        submitButton.layer.cornerRadius = 10
    }

    private func setupTableView() {
        templateTableView.delegate = self
        templateTableView.dataSource = self
        templateTableView.register(
            UINib(nibName: "HeadlineTemplateCell", bundle: nil),
            forCellReuseIdentifier: "HeadlineTemplateCell"
        )
        templateTableView.tableFooterView = UIView()
    }

    private func restoreExistingData() {
        if let existingText = viewModel?.model.headlineText {
            textField.text = existingText
        }
    }

    // MARK: - Actions

    @IBAction func backTapped(_ sender: UIButton) {
        applyToViewModel()
        stepDelegate?.stepDidTapBack(self)
    }

    @IBAction func skipTapped(_ sender: UIButton) {
        textField.text = ""
        viewModel?.clearHeadline()
        stepDelegate?.stepDidTapSkip(self)
    }

    @IBAction func submitTapped(_ sender: UIButton) {
        applyToViewModel()
        stepDelegate?.stepDidTapNext(self)
    }

    func applyToViewModel() {
        let text = textField.text ?? ""
        viewModel?.setHeadline(text: text, font: activeFont)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension AddTextStepViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeadlineTemplateCell", for: indexPath) as! HeadlineTemplateCell
        let template = templates[indexPath.row]
        cell.configure(with: template, isSelected: indexPath.row == selectedTemplateIndex)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        selectedTemplateIndex = indexPath.row
        tableView.reloadData()

        let template = templates[indexPath.row]
        textField.text = template.text
        activeFont = template.font
    }
}

// MARK: - UITextFieldDelegate

extension AddTextStepViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
