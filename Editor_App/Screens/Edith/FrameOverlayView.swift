//
//  FrameOverlayView.swift
//  Editor_App
//
//  Created by Antigravity on 20/08/2026.
//

import UIKit

class FrameOverlayView: UIView {
    
    var customBorderColor: UIColor? {
        didSet {
            setNeedsLayout()
            updateOverlay()
        }
    }
    
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
    private let accentBadgeLabel = UILabel()
    private let gradientBorderLayer = CAGradientLayer()
    private let secondaryBorderLayer = CAShapeLayer()
    private var sprocketLayers: [CALayer] = []
    
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
        
        accentBadgeLabel.isUserInteractionEnabled = false
        accentBadgeLabel.isHidden = true
        accentBadgeLabel.font = .systemFont(ofSize: 10, weight: .black)
        accentBadgeLabel.textAlignment = .center
        accentBadgeLabel.layer.cornerRadius = 4
        accentBadgeLabel.layer.masksToBounds = true
        addSubview(accentBadgeLabel)
        
        layer.addSublayer(gradientBorderLayer)
        gradientBorderLayer.isHidden = true
        
        layer.addSublayer(secondaryBorderLayer)
        secondaryBorderLayer.isHidden = true
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
        layer.mask = nil
        
        topBarView.isHidden = true
        bottomBarView.isHidden = true
        leftBarView.isHidden = true
        rightBarView.isHidden = true
        innerBorderView.isHidden = true
        accentBadgeLabel.isHidden = true
        gradientBorderLayer.isHidden = true
        secondaryBorderLayer.isHidden = true
        
        sprocketLayers.forEach { $0.removeFromSuperlayer() }
        sprocketLayers.removeAll()
    }
    
    private func updateOverlay() {
        resetStyles()
        
        guard let template = template, template.style != .none else {
            return
        }
        
        let effectiveColor = customBorderColor ?? template.borderColor
        let scale = min(bounds.width, bounds.height) / 300.0
        let effectiveScale = max(0.5, scale)
        
        switch template.style {
        case .none:
            break
            
        case .classic:
            // Classic White frame with thin inner accent inset
            layer.borderColor = effectiveColor.cgColor
            layer.borderWidth = max(4.0, template.borderWidth * effectiveScale)
            layer.cornerRadius = 0
            
            innerBorderView.isHidden = false
            let inset = max(4.0, template.borderWidth * effectiveScale) + 2.0
            innerBorderView.frame = bounds.insetBy(dx: inset, dy: inset)
            innerBorderView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            innerBorderView.layer.borderWidth = 1.0
            
        case .cinematic:
            // 21:9 Letterbox black bars with horizontal grain lines
            let barHeight = bounds.height * 0.14
            topBarView.isHidden = false
            topBarView.backgroundColor = .black
            topBarView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: barHeight)
            
            bottomBarView.isHidden = false
            bottomBarView.backgroundColor = .black
            bottomBarView.frame = CGRect(x: 0, y: bounds.height - barHeight, width: bounds.width, height: barHeight)
            
        case .rounded:
            layer.borderColor = effectiveColor.cgColor
            layer.borderWidth = max(3.0, template.borderWidth * effectiveScale)
            layer.cornerRadius = max(8.0, template.cornerRadius * effectiveScale)
            layer.masksToBounds = true
            
        case .polaroid:
            // Wide polaroid white border with bottom paper margin & text space
            let sideWidth = max(6.0, 14.0 * effectiveScale)
            let bottomHeight = max(24.0, 52.0 * effectiveScale)
            
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
            bottomBarView.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
            bottomBarView.frame = CGRect(x: 0, y: bounds.height - bottomHeight, width: bounds.width, height: bottomHeight)
            
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowRadius = 8.0
            layer.shadowOpacity = 0.4
            layer.shadowOffset = CGSize(width: 0, height: 4)
            layer.masksToBounds = false
            
        case .neonGlow:
            // Vibrant Cyan/Magenta Neon Glow Frame
            layer.borderColor = effectiveColor.cgColor
            layer.borderWidth = max(3.0, template.borderWidth * effectiveScale)
            layer.cornerRadius = max(6.0, template.cornerRadius * effectiveScale)
            layer.shadowColor = effectiveColor.cgColor
            layer.shadowRadius = max(6.0, 12.0 * effectiveScale)
            layer.shadowOpacity = 1.0
            layer.shadowOffset = .zero
            layer.masksToBounds = false
            
        case .vintage:
            // Antique double border with gold inner lining
            layer.borderColor = effectiveColor.cgColor
            layer.borderWidth = max(4.0, template.borderWidth * effectiveScale)
            layer.cornerRadius = max(4.0, template.cornerRadius * effectiveScale)
            
            innerBorderView.isHidden = false
            let borderWidth = max(4.0, template.borderWidth * effectiveScale)
            let inset = borderWidth + max(3.0, 4.0 * effectiveScale)
            innerBorderView.frame = bounds.insetBy(dx: inset, dy: inset)
            innerBorderView.layer.borderColor = UIColor(red: 0.95, green: 0.82, blue: 0.4, alpha: 0.9).cgColor
            innerBorderView.layer.borderWidth = max(1.5, 2.0 * effectiveScale)
            
        case .newsBroadcast:
            // Red Broadcast Frame with LIVE Badge
            layer.borderColor = (customBorderColor ?? UIColor.systemRed).cgColor
            layer.borderWidth = max(4.0, 6.0 * effectiveScale)
            layer.cornerRadius = 0
            
            topBarView.isHidden = false
            topBarView.backgroundColor = customBorderColor ?? .systemRed
            let topH = max(20.0, 30.0 * effectiveScale)
            topBarView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: topH)
            
            bottomBarView.isHidden = false
            bottomBarView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
            let bottomH = max(24.0, 38.0 * effectiveScale)
            bottomBarView.frame = CGRect(x: 0, y: bounds.height - bottomH, width: bounds.width, height: bottomH)
            
            accentBadgeLabel.isHidden = false
            accentBadgeLabel.text = " LIVE "
            accentBadgeLabel.textColor = .white
            accentBadgeLabel.backgroundColor = .systemRed
            accentBadgeLabel.frame = CGRect(x: 10, y: (topH - 18) / 2, width: 44, height: 18)
            
        case .sportsBroadcast:
            // Navy Blue & Gold Sports Frame
            let sportsColor = customBorderColor ?? UIColor(red: 0.1, green: 0.2, blue: 0.5, alpha: 1.0)
            layer.borderColor = sportsColor.cgColor
            layer.borderWidth = max(4.0, 6.0 * effectiveScale)
            layer.cornerRadius = 0
            
            topBarView.isHidden = false
            topBarView.backgroundColor = sportsColor
            let topH = max(18.0, 28.0 * effectiveScale)
            topBarView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: topH)
            
            bottomBarView.isHidden = false
            bottomBarView.backgroundColor = UIColor(red: 0.95, green: 0.75, blue: 0.1, alpha: 0.95)
            let bottomH = max(20.0, 32.0 * effectiveScale)
            bottomBarView.frame = CGRect(x: 0, y: bounds.height - bottomH, width: bounds.width, height: bottomH)
            
            accentBadgeLabel.isHidden = false
            accentBadgeLabel.text = " SCORE "
            accentBadgeLabel.textColor = .black
            accentBadgeLabel.backgroundColor = UIColor(red: 0.95, green: 0.75, blue: 0.1, alpha: 1.0)
            accentBadgeLabel.frame = CGRect(x: 10, y: (topH - 18) / 2, width: 50, height: 18)
            
        case .podcastShow:
            // Deep Purple Podcast Frame with Rounded Corners
            let podcastColor = customBorderColor ?? UIColor(red: 0.4, green: 0.1, blue: 0.6, alpha: 1.0)
            layer.borderColor = podcastColor.cgColor
            layer.borderWidth = max(4.0, 6.0 * effectiveScale)
            layer.cornerRadius = max(8.0, 16.0 * effectiveScale)
            layer.masksToBounds = true
            
            bottomBarView.isHidden = false
            bottomBarView.backgroundColor = UIColor(red: 0.2, green: 0.05, blue: 0.35, alpha: 0.9)
            let bottomH = max(24.0, 38.0 * effectiveScale)
            bottomBarView.frame = CGRect(x: 0, y: bounds.height - bottomH, width: bounds.width, height: bottomH)
            
        case .minimal:
            // Minimal Dark: Thin Charcoal Border with Soft Shadow
            layer.borderColor = (customBorderColor ?? UIColor.darkGray).cgColor
            layer.borderWidth = max(1.5, template.borderWidth * effectiveScale)
            layer.cornerRadius = max(4.0, template.cornerRadius * effectiveScale)
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowRadius = 6.0
            layer.shadowOpacity = 0.6
            layer.shadowOffset = CGSize(width: 0, height: 3)
            layer.masksToBounds = false
            
        case .gradient:
            // Vibrant Multicolor Gradient Border
            gradientBorderLayer.isHidden = false
            gradientBorderLayer.frame = bounds
            gradientBorderLayer.colors = [
                UIColor.systemPurple.cgColor,
                UIColor.systemPink.cgColor,
                UIColor.systemOrange.cgColor
            ]
            gradientBorderLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientBorderLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientBorderLayer.cornerRadius = max(6.0, template.cornerRadius * effectiveScale)
            
            let mask = CAShapeLayer()
            let bw = max(4.0, template.borderWidth * effectiveScale)
            let outerPath = UIBezierPath(roundedRect: bounds, cornerRadius: max(6.0, template.cornerRadius * effectiveScale))
            let innerPath = UIBezierPath(roundedRect: bounds.insetBy(dx: bw, dy: bw), cornerRadius: max(2.0, (template.cornerRadius - bw) * effectiveScale))
            outerPath.append(innerPath)
            mask.path = outerPath.cgPath
            mask.fillRule = .evenOdd
            gradientBorderLayer.mask = mask
            
        case .filmStrip:
            // 35mm Film Strip with White Sprocket Hole Perforations
            let barWidth = max(16.0, 24.0 * effectiveScale)
            leftBarView.isHidden = false
            leftBarView.backgroundColor = .black
            leftBarView.frame = CGRect(x: 0, y: 0, width: barWidth, height: bounds.height)
            
            rightBarView.isHidden = false
            rightBarView.backgroundColor = .black
            rightBarView.frame = CGRect(x: bounds.width - barWidth, y: 0, width: barWidth, height: bounds.height)
            
            // Draw sprocket hole rectangles
            let holeW: CGFloat = 6.0 * effectiveScale
            let holeH: CGFloat = 8.0 * effectiveScale
            let spacing: CGFloat = 16.0 * effectiveScale
            var yPos: CGFloat = spacing
            
            while yPos + holeH < bounds.height {
                let leftHole = CALayer()
                leftHole.backgroundColor = UIColor.white.cgColor
                leftHole.cornerRadius = 1.5
                leftHole.frame = CGRect(x: (barWidth - holeW) / 2.0, y: yPos, width: holeW, height: holeH)
                layer.addSublayer(leftHole)
                sprocketLayers.append(leftHole)
                
                let rightHole = CALayer()
                rightHole.backgroundColor = UIColor.white.cgColor
                rightHole.cornerRadius = 1.5
                rightHole.frame = CGRect(x: bounds.width - (barWidth + holeW) / 2.0, y: yPos, width: holeW, height: holeH)
                layer.addSublayer(rightHole)
                sprocketLayers.append(rightHole)
                
                yPos += holeH + spacing
            }
            
        case .glitch:
            // Offset Cyan & Pink Glitch Layers
            layer.borderColor = (customBorderColor ?? UIColor.systemPink).cgColor
            layer.borderWidth = max(3.0, template.borderWidth * effectiveScale)
            layer.cornerRadius = max(2.0, template.cornerRadius * effectiveScale)
            
            innerBorderView.isHidden = false
            let offset = max(3.0, 4.0 * effectiveScale)
            innerBorderView.frame = bounds.insetBy(dx: offset, dy: offset)
            innerBorderView.layer.borderColor = UIColor.systemCyan.cgColor
            innerBorderView.layer.borderWidth = max(2.0, 2.5 * effectiveScale)
            
            secondaryBorderLayer.isHidden = false
            let secPath = UIBezierPath(rect: bounds.insetBy(dx: -2, dy: -2))
            secondaryBorderLayer.path = secPath.cgPath
            secondaryBorderLayer.strokeColor = UIColor.systemCyan.withAlphaComponent(0.7).cgColor
            secondaryBorderLayer.fillColor = UIColor.clear.cgColor
            secondaryBorderLayer.lineWidth = 1.5
            
        case .splitDual:
            // Teal Frame with Center Dashed Line
            layer.borderColor = effectiveColor.cgColor
            layer.borderWidth = max(4.0, template.borderWidth * effectiveScale)
            
            innerBorderView.isHidden = false
            let midX = bounds.width / 2.0
            innerBorderView.frame = CGRect(x: midX - 1.0, y: 0, width: 2.0, height: bounds.height)
            innerBorderView.backgroundColor = effectiveColor
            
            accentBadgeLabel.isHidden = false
            accentBadgeLabel.text = " SPLIT "
            accentBadgeLabel.textColor = .white
            accentBadgeLabel.backgroundColor = effectiveColor
            accentBadgeLabel.frame = CGRect(x: midX - 22, y: 8, width: 44, height: 16)
        }
    }
}
