//
//  HamburgerView.swift
//  DrawerDemo
//
//  Created by Michael Inger on 17/08/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit

class HamburgerView: UIView, CAAnimationDelegate {
    
    var progress: CGFloat = 0 {
        didSet {
            update(to: progress)
        }
    }
    
    // MARK - Private
    
    private var padding: CGFloat = 10
    private var strokeWidth: CGFloat = 4
    
    private lazy var top: CAShapeLayer = {
        return self.applyDefaults(to: CAShapeLayer())
    }()
    
    private lazy var mid: CAShapeLayer = {
        return self.applyDefaults(to: CAShapeLayer())
    }()
    
    private lazy var btm: CAShapeLayer = {
        return self.applyDefaults(to: CAShapeLayer())
    }()
    
    override func awakeFromNib() {
        mid.actions = [
            "strokeStart": NSNull(),
            "strokeEnd": NSNull(),
            "transform": NSNull()
        ]
    }
    
    private func update(to progress: CGFloat) {
        if mid.animationKeys()?.count ?? 0 == 0 {
            print(mid.strokeEnd)
            mid.timeOffset = 0
            mid.strokeEnd == strokeEndForMid(0) ? animateToClose() : animateToClose(false)
            mid.speed = 0
        } else if mid.speed == 0 {
            mid.timeOffset = CFTimeInterval(progress * 0.6)
        }
    }
    
    var blockProgressSideEffect = false
    
    func animateToClose(_ close: Bool = true) {
        let strokeStart = CABasicAnimation(keyPath: "strokeStart")
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")

        strokeStart.toValue = strokeStartForMid(close ? 1 : 0)
        strokeStart.duration = 0.5
        strokeStart.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, -0.4, 0.5, 1)
        
        strokeEnd.toValue = strokeEndForMid(close ? 1 : 0)
        strokeEnd.duration = 0.6
        strokeEnd.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, -0.4, 0.5, 1)
        
        if mid.speed == 0 {
            strokeStart.fromValue = mid.presentation()!.value(forKeyPath: "strokeStart")
            strokeEnd.fromValue = mid.presentation()!.value(forKeyPath: "strokeEnd")
            mid.speed = 1
            mid.timeOffset = mid.beginTime + Date().timeIntervalSince1970
        }
        
        mid.removeAllAnimations()
        mid.applyAnimation(strokeStart)
        mid.applyAnimation(strokeEnd)
    }
    
    private func strokeStartForMid(_ progress: CGFloat) -> CGFloat {
        return progress == 0 ? 0.028 : 0.325
    }
    
    private func strokeEndForMid(_ progress: CGFloat) -> CGFloat {
        return progress == 0 ? 0.111 : 0.91
    }
    
    override func layoutSubviews() {
        padding = 0.05 * bounds.width
        let frame = self.bounds.insetBy(dx: padding, dy: padding)
        let midBounds = CGRect(origin: .zero, size: frame.size)
        strokeWidth = 0.05769230769 * midBounds.width
        
        // Compute mid path
        let w = midBounds.width
        let h = midBounds.height
        let midX = 0.5 * w
        let midY = 0.5 * h
        let padX = 0.037037 * w
        let padY = 0.037037 * h
        let maxPadX = 0.962962963 * w
        let maxPadY = 0.962962963 * h
        let qX = 0.2437037 * w
        let qY = 0.2437037 * h
        let qMaxX = 0.7562962963 * w
        let qMaxY = 0.7562962963 * h
        let pt1 = 0.1851851852 * w
        let pt2 = 0.7407407407 * w
        let ctp1 = 0.2222222222 * w
        let ctp2 = 0.5188888889 * w
        let ctp3 = 1.0355555556 * w
        let ctp4 = 0.9346296296 * w
        let ctp5 = 0.785 * w
        let path = CGMutablePath()
        path.move(to: CGPoint(x: pt1, y: midY))
        path.addCurve(to: CGPoint(x: pt2, y: midY), control1: CGPoint(x: ctp1, y: midY), control2: CGPoint(x: ctp2, y: midY))
        path.addCurve(to: CGPoint(x: midX, y: padY), control1: CGPoint(x: ctp3, y: midY), control2: CGPoint(x: ctp4, y: padY))
        path.addCurve(to: CGPoint(x: padX, y: midY), control1: CGPoint(x: qX, y: padY), control2: CGPoint(x: padX, y: qY))
        path.addCurve(to: CGPoint(x: midX, y: maxPadY), control1: CGPoint(x: padX, y: qMaxY), control2: CGPoint(x: qX, y: maxPadY))
        path.addCurve(to: CGPoint(x: maxPadX, y: midY), control1: CGPoint(x: qMaxX, y: maxPadY), control2: CGPoint(x: maxPadX, y: qMaxY))
        path.addCurve(to: CGPoint(x: midX, y: padY), control1: CGPoint(x: maxPadX, y: qY), control2: CGPoint(x: ctp5, y: padY))
        path.addCurve(to: CGPoint(x: padX, y: midY), control1: CGPoint(x: qX, y: padY), control2: CGPoint(x: padX, y: qY))
        
        // Setup mid layer
        mid.position = CGPoint(x: frame.midX, y: frame.midY)
        mid.bounds = midBounds
        mid.path = path
        mid.lineWidth = strokeWidth
        mid.strokeStart = strokeStartForMid(progress)
        mid.strokeEnd = strokeEndForMid(progress)
        
        // Cumpute line path
        let lineWidth = 0.4815 * w
        let topLineY = 0.3333333333 * h
        let lineBounds = CGRect(origin: .zero, size: CGSize(width: lineWidth + strokeWidth * 2, height: strokeWidth))
        let linePath = CGMutablePath()
        linePath.move(to: CGPoint(x: strokeWidth, y: lineBounds.midY))
        linePath.addLine(to: CGPoint(x: lineWidth + strokeWidth, y: lineBounds.midY))
        
        // Top layer
        top.bounds = lineBounds
        top.position = CGPoint(x: frame.midX, y: frame.minY + topLineY)
        top.path = linePath
        top.lineWidth = strokeWidth

        // Bottom layer
        btm.bounds = lineBounds
        btm.position = CGPoint(x: frame.midX, y: frame.maxY - topLineY)
        btm.path = linePath
        btm.lineWidth = strokeWidth
        super.layoutSubviews()
    }
    
    private func applyDefaults(to layer: CAShapeLayer) -> CAShapeLayer {
        self.layer.addSublayer(layer)
        layer.strokeColor = UIColor.blue.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = strokeWidth
        layer.miterLimit = 100 // strokeWidth
        layer.lineCap = kCALineCapRound
        return layer
    }
}

extension CALayer {
    
    func applyAnimation(_ animation: CABasicAnimation) {
        let copy = animation.copy() as! CABasicAnimation
        if copy.fromValue == nil {
            copy.fromValue = self.presentation()!.value(forKeyPath: copy.keyPath!)
        }
        copy.isRemovedOnCompletion = true
        self.add(copy, forKey: copy.keyPath)
        self.setValue(copy.toValue, forKeyPath:copy.keyPath!)
    }
}
