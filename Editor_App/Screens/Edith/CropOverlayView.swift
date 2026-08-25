//
//  CropOverlayView.swift
//  Editor_App
//
//  Created by Antigravity on 25/08/2026.
//

import UIKit

protocol CropOverlayDelegate: AnyObject {
    func cropOverlayDidFinish(normalizedCropRect: CGRect)
    func cropOverlayDidCancel()
}

class CropOverlayView: UIView {
    
    weak var delegate: CropOverlayDelegate?
    
    private var cropRect: CGRect = .zero
    private var activeHandle: HandleTag = .none
    private var touchOffset: CGPoint = .zero
    
    private enum HandleTag {
        case none
        case topLeft, topRight, bottomLeft, bottomRight
        case top, bottom, left, right
        case move
    }
    
    private let handleSize: CGFloat = 24.0
    private let minCropSize: CGFloat = 60.0
    
    private let dimmingLayer = CAShapeLayer()
    private let gridLayer = CAShapeLayer()
    
    private let topLeftHandle = UIView()
    private let topRightHandle = UIView()
    private let bottomLeftHandle = UIView()
    private let bottomRightHandle = UIView()
    
    private let topHandle = UIView()
    private let bottomHandle = UIView()
    private let leftHandle = UIView()
    private let rightHandle = UIView()
    
    private let toolbarView = UIView()
    private let doneButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        
        layer.addSublayer(dimmingLayer)
        layer.addSublayer(gridLayer)
        
        setupHandles()
        setupToolbar()
    }
    
    private func setupHandles() {
        let handles = [
            topLeftHandle, topRightHandle, bottomLeftHandle, bottomRightHandle,
            topHandle, bottomHandle, leftHandle, rightHandle
        ]
        
        handles.forEach {
            $0.backgroundColor = .white
            $0.layer.borderColor = UIColor.systemBlue.cgColor
            $0.layer.borderWidth = 2.0
            $0.layer.cornerRadius = handleSize / 2.0
            $0.isUserInteractionEnabled = false
            addSubview($0)
        }
    }
    
    private func setupToolbar() {
        toolbarView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        toolbarView.layer.cornerRadius = 12
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(toolbarView)
        
        titleLabel.text = "Drag handles to crop video"
        titleLabel.font = .systemFont(ofSize: 13, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toolbarView.addSubview(titleLabel)
        
        resetButton.setTitle("Reset", for: .normal)
        resetButton.setTitleColor(.systemYellow, for: .normal)
        resetButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        toolbarView.addSubview(resetButton)
        
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.systemGreen, for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        toolbarView.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            toolbarView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            toolbarView.centerXAnchor.constraint(equalTo: centerXAnchor),
            toolbarView.widthAnchor.constraint(equalTo: widthAnchor, constant: -24),
            toolbarView.heightAnchor.constraint(equalToConstant: 44),
            
            resetButton.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 12),
            resetButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: toolbarView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            
            doneButton.trailingAnchor.constraint(equalTo: toolbarView.trailingAnchor, constant: -12),
            doneButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if cropRect == .zero {
            let inset: CGFloat = 16.0
            cropRect = bounds.insetBy(dx: inset, dy: inset)
        }
        updateCropUI()
    }
    
    private func updateCropUI() {
        // Update dimming mask
        let path = UIBezierPath(rect: bounds)
        let cropPath = UIBezierPath(rect: cropRect)
        path.append(cropPath)
        dimmingLayer.path = path.cgPath
        dimmingLayer.fillRule = .evenOdd
        dimmingLayer.fillColor = UIColor.black.withAlphaComponent(0.55).cgColor
        
        // Update grid lines & border
        let gridPath = UIBezierPath(rect: cropRect)
        
        // 3x3 grid lines
        let thirdW = cropRect.width / 3.0
        let thirdH = cropRect.height / 3.0
        
        gridPath.move(to: CGPoint(x: cropRect.minX + thirdW, y: cropRect.minY))
        gridPath.addLine(to: CGPoint(x: cropRect.minX + thirdW, y: cropRect.maxY))
        
        gridPath.move(to: CGPoint(x: cropRect.minX + thirdW * 2, y: cropRect.minY))
        gridPath.addLine(to: CGPoint(x: cropRect.minX + thirdW * 2, y: cropRect.maxY))
        
        gridPath.move(to: CGPoint(x: cropRect.minX, y: cropRect.minY + thirdH))
        gridPath.addLine(to: CGPoint(x: cropRect.maxX, y: cropRect.minY + thirdH))
        
        gridPath.move(to: CGPoint(x: cropRect.minX, y: cropRect.minY + thirdH * 2))
        gridPath.addLine(to: CGPoint(x: cropRect.maxX, y: cropRect.minY + thirdH * 2))
        
        gridLayer.path = gridPath.cgPath
        gridLayer.strokeColor = UIColor.white.withAlphaComponent(0.8).cgColor
        gridLayer.lineWidth = 1.5
        gridLayer.fillColor = UIColor.clear.cgColor
        
        // Position handles
        let hs = handleSize
        topLeftHandle.center = CGPoint(x: cropRect.minX, y: cropRect.minY)
        topLeftHandle.bounds = CGRect(x: 0, y: 0, width: hs, height: hs)
        
        topRightHandle.center = CGPoint(x: cropRect.maxX, y: cropRect.minY)
        topRightHandle.bounds = CGRect(x: 0, y: 0, width: hs, height: hs)
        
        bottomLeftHandle.center = CGPoint(x: cropRect.minX, y: cropRect.maxY)
        bottomLeftHandle.bounds = CGRect(x: 0, y: 0, width: hs, height: hs)
        
        bottomRightHandle.center = CGPoint(x: cropRect.maxX, y: cropRect.maxY)
        bottomRightHandle.bounds = CGRect(x: 0, y: 0, width: hs, height: hs)
        
        topHandle.center = CGPoint(x: cropRect.midX, y: cropRect.minY)
        topHandle.bounds = CGRect(x: 0, y: 0, width: hs, height: hs)
        
        bottomHandle.center = CGPoint(x: cropRect.midX, y: cropRect.maxY)
        bottomHandle.bounds = CGRect(x: 0, y: 0, width: hs, height: hs)
        
        leftHandle.center = CGPoint(x: cropRect.minX, y: cropRect.midY)
        leftHandle.bounds = CGRect(x: 0, y: 0, width: hs, height: hs)
        
        rightHandle.center = CGPoint(x: cropRect.maxX, y: cropRect.midY)
        rightHandle.bounds = CGRect(x: 0, y: 0, width: hs, height: hs)
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pt = touch.location(in: self)
        
        let touchRadius: CGFloat = 28.0
        
        if distance(pt, topLeftHandle.center) < touchRadius {
            activeHandle = .topLeft
        } else if distance(pt, topRightHandle.center) < touchRadius {
            activeHandle = .topRight
        } else if distance(pt, bottomLeftHandle.center) < touchRadius {
            activeHandle = .bottomLeft
        } else if distance(pt, bottomRightHandle.center) < touchRadius {
            activeHandle = .bottomRight
        } else if distance(pt, topHandle.center) < touchRadius {
            activeHandle = .top
        } else if distance(pt, bottomHandle.center) < touchRadius {
            activeHandle = .bottom
        } else if distance(pt, leftHandle.center) < touchRadius {
            activeHandle = .left
        } else if distance(pt, rightHandle.center) < touchRadius {
            activeHandle = .right
        } else if cropRect.contains(pt) {
            activeHandle = .move
            touchOffset = CGPoint(x: pt.x - cropRect.origin.x, y: pt.y - cropRect.origin.y)
        } else {
            activeHandle = .none
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, activeHandle != .none else { return }
        let pt = touch.location(in: self)
        
        var newRect = cropRect
        let bounds = self.bounds
        
        switch activeHandle {
        case .topLeft:
            let newMinX = min(pt.x, cropRect.maxX - minCropSize)
            let newMinY = min(pt.y, cropRect.maxY - minCropSize)
            newRect = CGRect(x: max(0, newMinX), y: max(0, newMinY), width: cropRect.maxX - max(0, newMinX), height: cropRect.maxY - max(0, newMinY))
            
        case .topRight:
            let newMaxX = max(pt.x, cropRect.minX + minCropSize)
            let newMinY = min(pt.y, cropRect.maxY - minCropSize)
            newRect = CGRect(x: cropRect.minX, y: max(0, newMinY), width: min(bounds.width, newMaxX) - cropRect.minX, height: cropRect.maxY - max(0, newMinY))
            
        case .bottomLeft:
            let newMinX = min(pt.x, cropRect.maxX - minCropSize)
            let newMaxY = max(pt.y, cropRect.minY + minCropSize)
            newRect = CGRect(x: max(0, newMinX), y: cropRect.minY, width: cropRect.maxX - max(0, newMinX), height: min(bounds.height, newMaxY) - cropRect.minY)
            
        case .bottomRight:
            let newMaxX = max(pt.x, cropRect.minX + minCropSize)
            let newMaxY = max(pt.y, cropRect.minY + minCropSize)
            newRect = CGRect(x: cropRect.minX, y: cropRect.minY, width: min(bounds.width, newMaxX) - cropRect.minX, height: min(bounds.height, newMaxY) - cropRect.minY)
            
        case .top:
            let newMinY = min(pt.y, cropRect.maxY - minCropSize)
            newRect.origin.y = max(0, newMinY)
            newRect.size.height = cropRect.maxY - newRect.origin.y
            
        case .bottom:
            let newMaxY = max(pt.y, cropRect.minY + minCropSize)
            newRect.size.height = min(bounds.height, newMaxY) - cropRect.minY
            
        case .left:
            let newMinX = min(pt.x, cropRect.maxX - minCropSize)
            newRect.origin.x = max(0, newMinX)
            newRect.size.width = cropRect.maxX - newRect.origin.x
            
        case .right:
            let newMaxX = max(pt.x, cropRect.minX + minCropSize)
            newRect.size.width = min(bounds.width, newMaxX) - cropRect.minX
            
        case .move:
            var newX = pt.x - touchOffset.x
            var newY = pt.y - touchOffset.y
            newX = max(0, min(bounds.width - cropRect.width, newX))
            newY = max(0, min(bounds.height - cropRect.height, newY))
            newRect.origin = CGPoint(x: newX, y: newY)
            
        case .none:
            break
        }
        
        cropRect = newRect
        updateCropUI()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeHandle = .none
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeHandle = .none
    }
    
    private func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        return hypot(p1.x - p2.x, p1.y - p2.y)
    }
    
    // MARK: - Actions
    
    @objc private func resetTapped() {
        let inset: CGFloat = 8.0
        cropRect = bounds.insetBy(dx: inset, dy: inset)
        updateCropUI()
    }
    
    @objc private func doneTapped() {
        guard bounds.width > 0 && bounds.height > 0 else { return }
        let normX = cropRect.origin.x / bounds.width
        let normY = cropRect.origin.y / bounds.height
        let normW = cropRect.width / bounds.width
        let normH = cropRect.height / bounds.height
        
        let normalized = CGRect(x: normX, y: normY, width: normW, height: normH)
        delegate?.cropOverlayDidFinish(normalizedCropRect: normalized)
        removeFromSuperview()
    }
}
