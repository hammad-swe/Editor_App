//
//  FrameCustomizationSheetViewController.swift
//  Editor_App
//
//  Created by Antigravity on 24/08/2026.
//

import UIKit

protocol FrameCustomizationDelegate: AnyObject {
    func customizationDidChange(color: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat, logoShape: LogoShape)
    func customizationDidResetLogoPosition()
    func customizationDidRequestSaveTemplate(name: String)
}

class FrameCustomizationSheetViewController: UIViewController {

    weak var delegate: FrameCustomizationDelegate?
    
    var currentColor: UIColor = .systemBlue
    var currentBorderWidth: CGFloat = 8
    var currentCornerRadius: CGFloat = 0
    var currentLogoShape: LogoShape = .square
    
    private let titleLabel = UILabel()
    private let colorPickerLabel = UILabel()
    private let colorWell = UIColorWell()
    
    private let borderWidthLabel = UILabel()
    private let borderWidthSlider = UISlider()
    
    private let cornerRadiusLabel = UILabel()
    private let cornerRadiusSlider = UISlider()
    
    private let logoShapeLabel = UILabel()
    private let logoShapeSegmentedControl = UISegmentedControl(items: LogoShape.allCases.map { $0.rawValue })
    
    private let resetLogoPosButton = UIButton(type: .system)
    private let saveTemplateButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.text = "Customize Frame & Logo"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        
        colorPickerLabel.text = "Frame Border Color"
        colorPickerLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        
        colorWell.selectedColor = currentColor
        colorWell.addTarget(self, action: #selector(colorChanged), for: .valueChanged)
        
        borderWidthLabel.text = "Border Width: \(Int(currentBorderWidth))pt"
        borderWidthLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        borderWidthSlider.minimumValue = 1
        borderWidthSlider.maximumValue = 24
        borderWidthSlider.value = Float(currentBorderWidth)
        borderWidthSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        
        cornerRadiusLabel.text = "Corner Radius: \(Int(currentCornerRadius))pt"
        cornerRadiusLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        cornerRadiusSlider.minimumValue = 0
        cornerRadiusSlider.maximumValue = 30
        cornerRadiusSlider.value = Float(currentCornerRadius)
        cornerRadiusSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        
        logoShapeLabel.text = "Logo Watermark Shape"
        logoShapeLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        
        if let idx = LogoShape.allCases.firstIndex(of: currentLogoShape) {
            logoShapeSegmentedControl.selectedSegmentIndex = idx
        } else {
            logoShapeSegmentedControl.selectedSegmentIndex = 0
        }
        logoShapeSegmentedControl.selectedSegmentTintColor = .systemBlue
        let normalAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: 11, weight: .medium)]
        let selectedAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 11, weight: .bold)]
        logoShapeSegmentedControl.setTitleTextAttributes(normalAttrs, for: .normal)
        logoShapeSegmentedControl.setTitleTextAttributes(selectedAttrs, for: .selected)
        logoShapeSegmentedControl.addTarget(self, action: #selector(logoShapeChanged), for: .valueChanged)
        
        resetLogoPosButton.setTitle("Reset Logo Position", for: .normal)
        resetLogoPosButton.setTitleColor(.systemRed, for: .normal)
        resetLogoPosButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        resetLogoPosButton.addTarget(self, action: #selector(resetLogoPosTapped), for: .touchUpInside)
        
        saveTemplateButton.setTitle("Save as Custom Template", for: .normal)
        saveTemplateButton.backgroundColor = .systemBlue
        saveTemplateButton.setTitleColor(.white, for: .normal)
        saveTemplateButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        saveTemplateButton.layer.cornerRadius = 12
        saveTemplateButton.addTarget(self, action: #selector(saveTemplateTapped), for: .touchUpInside)
        
        let colorStack = UIStackView(arrangedSubviews: [colorPickerLabel, colorWell])
        colorStack.axis = .horizontal
        colorStack.alignment = .center
        colorStack.distribution = .equalSpacing
        
        let mainStack = UIStackView(arrangedSubviews: [
            titleLabel,
            colorStack,
            borderWidthLabel,
            borderWidthSlider,
            cornerRadiusLabel,
            cornerRadiusSlider,
            logoShapeLabel,
            logoShapeSegmentedControl,
            resetLogoPosButton,
            saveTemplateButton
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 14
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveTemplateButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func colorChanged() {
        if let color = colorWell.selectedColor {
            currentColor = color
            notifyDelegate()
        }
    }
    
    @objc private func sliderChanged() {
        currentBorderWidth = CGFloat(borderWidthSlider.value)
        currentCornerRadius = CGFloat(cornerRadiusSlider.value)
        borderWidthLabel.text = "Border Width: \(Int(currentBorderWidth))pt"
        cornerRadiusLabel.text = "Corner Radius: \(Int(currentCornerRadius))pt"
        notifyDelegate()
    }
    
    @objc private func logoShapeChanged() {
        let idx = logoShapeSegmentedControl.selectedSegmentIndex
        if idx < LogoShape.allCases.count {
            currentLogoShape = LogoShape.allCases[idx]
            notifyDelegate()
        }
    }
    
    @objc private func resetLogoPosTapped() {
        delegate?.customizationDidResetLogoPosition()
    }
    
    @objc private func saveTemplateTapped() {
        let alert = UIAlertController(title: "Save Custom Template", message: "Enter a name for your custom template frame:", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "My Custom Frame"
            tf.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self, weak alert] _ in
            guard let name = alert?.textFields?.first?.text, !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            self?.delegate?.customizationDidRequestSaveTemplate(name: name)
            self?.dismiss(animated: true)
        }))
        present(alert, animated: true)
    }
    
    private func notifyDelegate() {
        delegate?.customizationDidChange(
            color: currentColor,
            borderWidth: currentBorderWidth,
            cornerRadius: currentCornerRadius,
            logoShape: currentLogoShape
        )
    }
}
