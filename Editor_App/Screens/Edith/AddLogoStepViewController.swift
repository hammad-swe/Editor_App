//
//  AddLogoStepViewController.swift
//  Editor_App
//
//  Created by Antigravity on 19/08/2026.
//

import UIKit
import PhotosUI

class AddLogoStepViewController: UIViewController, EditorStepViewController {

    weak var stepDelegate: EditorStepDelegate?
    var viewModel: VideoEditingViewModel!

    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var logoPreviewImageView: UIImageView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var templateTableView: UITableView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    private var templates: [LogoTemplate] = []
    private var selectedTemplateIndex: Int?
    private var selectedFileName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Add Logo"

        templates = TemplateManager.shared.logoTemplates()
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
        stepLabel.text = "Step 5 of \(viewModel?.totalSteps ?? 6): Add Logo to Video"

        if logoPreviewImageView != nil {
            logoPreviewImageView.layer.cornerRadius = 8
            logoPreviewImageView.clipsToBounds = true
            logoPreviewImageView.contentMode = .scaleAspectFit
            logoPreviewImageView.layer.borderWidth = 1
            logoPreviewImageView.layer.borderColor = UIColor.systemGray4.cgColor
        }

        uploadButton.layer.cornerRadius = 8
        removeButton.layer.cornerRadius = 8
        removeButton.isHidden = true

        backButton.layer.cornerRadius = 10
        skipButton.layer.cornerRadius = 10
        nextButton.layer.cornerRadius = 10

        if let vm = viewModel {
            backButton.isEnabled = !vm.isFirstStep
            backButton.alpha = vm.isFirstStep ? 0.5 : 1.0
        }
    }

    private func setupTableView() {
        templateTableView.delegate = self
        templateTableView.dataSource = self
        templateTableView.register(
            UINib(nibName: "LogoTemplateCell", bundle: nil),
            forCellReuseIdentifier: "LogoTemplateCell"
        )
        templateTableView.tableFooterView = UIView()
    }

    private func restoreExistingData() {
        if let existingLogo = viewModel?.model.logoImage {
            logoPreviewImageView?.image = existingLogo
            removeButton.isHidden = false
            uploadButton.setTitle("Change Logo", for: .normal)
            fileNameLabel?.text = selectedFileName ?? "Selected Logo"
        } else {
            fileNameLabel?.text = "No logo selected"
        }
    }

    // MARK: - Actions

    @IBAction func uploadLogoTapped(_ sender: UIButton) {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @IBAction func removeLogoTapped(_ sender: UIButton) {
        logoPreviewImageView?.image = nil
        removeButton.isHidden = true
        uploadButton.setTitle("Upload Logo", for: .normal)
        fileNameLabel?.text = "No logo selected"
        selectedTemplateIndex = nil
        selectedFileName = nil
        templateTableView.reloadData()
        viewModel?.clearLogo()
    }

    @IBAction func backTapped(_ sender: UIButton) {
        stepDelegate?.stepDidTapBack(self)
    }

    @IBAction func skipTapped(_ sender: UIButton) {
        logoPreviewImageView?.image = nil
        fileNameLabel?.text = "No logo selected"
        viewModel?.clearLogo()
        stepDelegate?.stepDidTapSkip(self)
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        applyToViewModel()
        stepDelegate?.stepDidTapNext(self)
    }

    func applyToViewModel() {
        if let image = logoPreviewImageView?.image {
            let defaultFrame = CGRect(x: 16, y: 16, width: 60, height: 60)
            viewModel?.setLogo(image: image, frame: defaultFrame)
        } else {
            viewModel?.clearLogo()
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension AddLogoStepViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogoTemplateCell", for: indexPath) as! LogoTemplateCell
        let template = templates[indexPath.row]
        cell.configure(with: template, isSelected: indexPath.row == selectedTemplateIndex)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        selectedTemplateIndex = indexPath.row
        tableView.reloadData()

        let template = templates[indexPath.row]
        logoPreviewImageView?.image = template.image
        selectedFileName = "\(template.name).png"
        fileNameLabel?.text = "Selected File: \(template.name).png"
        removeButton.isHidden = false
        uploadButton.setTitle("Change Logo", for: .normal)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension AddLogoStepViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else { return }
        let provider = result.itemProvider

        let filename = provider.suggestedName.map { "\($0).png" } ?? "Uploaded_Logo.png"

        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self = self, let uiImage = image as? UIImage else { return }
                DispatchQueue.main.async {
                    self.selectedTemplateIndex = nil
                    self.templateTableView.reloadData()
                    self.logoPreviewImageView?.image = uiImage
                    self.selectedFileName = filename
                    self.fileNameLabel?.text = "Uploaded File: \(filename)"
                    self.removeButton.isHidden = false
                    self.uploadButton.setTitle("Change Logo", for: .normal)
                }
            }
        }
    }
}
