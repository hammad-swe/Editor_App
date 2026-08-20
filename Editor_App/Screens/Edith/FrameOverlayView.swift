//
//  FrameOverlayView.swift
//  Editor_App
//
//  Created by Antigravity on 20/08/2026.
//

import UIKit

class FrameOverlayView: UIView {
    
    var template: FrameTemplate? {
        didSet {
            setNeedsLayout()
            updateOverlay()
        }
    }
    
    private let topBarView = UIView()
    private let bottomBarView = UIView()
    private let leftBarView = UIView()
    private let rightBarView = UIView()
    private let innerBorderView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        isUserInteractionEnabled = false
        backgroundColor = .clear
        
        [topBarView, bottomBarView, leftBarView, rightBarView, innerBorderView].forEach {
            $0.isUserInteractionEnabled = false
            $0.isHidden = true
            addSubview($0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateOverlay()
    }
    
    private func resetStyles() {
        layer.borderWidth = 0
        layer.borderColor = nil
        layer.cornerRadius = 0
        layer.shadowOpacity = 0
        layer.shadowColor = nil
        layer.shadowRadius = 0
        layer.shadowOffset = .zero
        
        topBarView.isHidden = true
        bottomBarView.isHidden = true
        leftBarView.isHidden = true
        rightBarView.isHidden = true
        innerBorderView.isHidden = true
    }
    
    private func updateOverlay() {
        resetStyles()
        
        guard let template = template, template.style != .none else {
            return
        }
        
        let scale = min(bounds.width, bounds.height) / 300.0
        let effectiveScale = max(0.5, scale)
        
        switch template.style {
        case .none:
            break
            
        case .classic:
            layer.borderColor = template.borderColor.cgColor
            layer.borderWidth = max(2.0, template.borderWidth * effectiveScale)
            layer.cornerRadius = 0
            
        case .cinematic:
            let barHeight = bounds.height * 0.12
            topBarView.isHidden = false
            topBarView.backgroundColor = .black
            topBarView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: barHeight)
            
            bottomBarView.isHidden = false
            bottomBarView.backgroundColor = .black
            bottomBarView.frame = CGRect(x: 0, y: bounds.height - barHeight, width: bounds.width, height: barHeight)
            
        case .rounded:
            layer.borderColor = template.borderColor.cgColor
            layer.borderWidth = max(2.0, template.borderWidth * effectiveScale)
            layer.cornerRadius = max(4.0, template.cornerRadius * effectiveScale)
            layer.masksToBounds = true
            
        case .polaroid:
            let sideWidth = max(4.0, 14.0 * effectiveScale)
            let bottomHeight = max(12.0, 48.0 * effectiveScale)
            
            topBarView.isHidden = false
            topBarView.backgroundColor = .white
            topBarView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: sideWidth)
            
            leftBarView.isHidden = false
            leftBarView.backgroundColor = .white
            leftBarView.frame = CGRect(x: 0, y: 0, width: sideWidth, height: bounds.height)
            
            rightBarView.isHidden = false
            rightBarView.backgroundColor = .white
            rightBarView.frame = CGRect(x: bounds.width - sideWidth, y: 0, width: sideWidth, height: bounds.height)
            
            bottomBarView.isHidden = false
            bottomBarView.backgroundColor = .white
            bottomBarView.frame = CGRect(x: 0, y: bounds.height - bottomHeight, width: bounds.width, height: bottomHeight)
            
        case .neonGlow:
            layer.borderColor = template.borderColor.cgColor
            layer.borderWidth = max(2.0, template.borderWidth * effectiveScale)
            layer.cornerRadius = max(4.0, template.cornerRadius * effectiveScale)
            layer.shadowColor = template.borderColor.cgColor
            layer.shadowRadius = max(4.0, 10.0 * effectiveScale)
            layer.shadowOpacity = 0.95
            layer.shadowOffset = .zero
            layer.masksToBounds = false
            
        case .vintage:
            layer.borderColor = template.borderColor.cgColor
            layer.borderWidth = max(2.0, template.borderWidth * effectiveScale)
            layer.cornerRadius = max(2.0, template.cornerRadius * effectiveScale)
            
            innerBorderView.isHidden = false
            let borderWidth = max(2.0, template.borderWidth * effectiveScale)
            let inset = borderWidth + max(2.0, 3.0 * effectiveScale)
            innerBorderView.frame = bounds.insetBy(dx: inset, dy: inset)
            innerBorderView.layer.borderColor = UIColor(red: 0.95, green: 0.85, blue: 0.6, alpha: 0.8).cgColor
            innerBorderView.layer.borderWidth = max(1.0, 1.5 * effectiveScale)
            
        case .newsBroadcast:
            layer.borderColor = UIColor.systemRed.cgColor
            layer.borderWidth = max(3.0, 6.0 * effectiveScale)
            layer.cornerRadius = 0
            
            topBarView.isHidden = false
            topBarView.backgroundColor = .systemRed
            topBarView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: max(16.0, 28.0 * effectiveScale))
            
            bottomBarView.isHidden = false
            bottomBarView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            bottomBarView.frame = CGRect(x: 0, y: bounds.height - max(20.0, 36.0 * effectiveScale), width: bounds.width, height: max(20.0, 36.0 * effectiveScale))
            
        case .sportsBroadcast:
            layer.borderColor = UIColor(red: 0.1, green: 0.2, blue: 0.5, alpha: 1.0).cgColor
            layer.borderWidth = max(3.0, 6.0 * effectiveScale)
            layer.cornerRadius = 0
            
            topBarView.isHidden = false
            topBarView.backgroundColor = UIColor(red: 0.1, green: 0.2, blue: 0.5, alpha: 1.0)
            topBarView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: max(16.0, 26.0 * effectiveScale))
            
            bottomBarView.isHidden = false
            bottomBarView.backgroundColor = UIColor(red: 0.9, green: 0.7, blue: 0.1, alpha: 0.9)
            bottomBarView.frame = CGRect(x: 0, y: bounds.height - max(18.0, 32.0 * effectiveScale), width: bounds.width, height: max(18.0, 32.0 * effectiveScale))
            
        case .podcastShow:
            layer.borderColor = UIColor(red: 0.4, green: 0.1, blue: 0.6, alpha: 1.0).cgColor
            layer.borderWidth = max(3.0, 6.0 * effectiveScale)
            layer.cornerRadius = max(6.0, 16.0 * effectiveScale)
            layer.masksToBounds = true
            
            bottomBarView.isHidden = false
            bottomBarView.backgroundColor = UIColor(red: 0.2, green: 0.05, blue: 0.35, alpha: 0.85)
            bottomBarView.frame = CGRect(x: 0, y: bounds.height - max(20.0, 36.0 * effectiveScale), width: bounds.width, height: max(20.0, 36.0 * effectiveScale))
        }
    }
}
