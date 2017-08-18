//
//  HamburgerView.swift
//  DrawerDemo
//
//  Created by Michael Inger on 17/08/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit

class HamburgerView: UIView, CAAnimationDelegate {
    
    enum Mode {
        case hamburger
        case close
    }
    
    var progress: CGFloat = 0 {
        didSet {
            update(to: progress)
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
                updateTintColor()
        }
    }
    
    func animateTo(_ mode: HamburgerView.Mode) {
        let strokeStart = CABasicAnimation(Key.strokeStart, toVal: strkStart(mode), duration: 0.5)
        strokeStart.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, -0.4, 0.5, 1)
        let strokeEnd = CABasicAnimation(Key.strokeEnd, toVal: strkEnd(mode), duration: 0.6)
        strokeEnd.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, -0.4, 0.5, 1)
        if mid.speed == 0 {
            strokeStart.fromValue = mid.presentation()?.value(forKeyPath: Key.strokeStart)
            strokeEnd.fromValue = mid.presentation()?.value(forKeyPath: Key.strokeEnd)
            mid.speed = 1
            mid.timeOffset = mid.beginTime + Date().timeIntervalSince1970
        }
        mid.removeAllAnimations()
        mid.applyAnimation(strokeStart)
        mid.applyAnimation(strokeEnd)
    }
    
    override func layoutSubviews() {
        initialSetupIfNeeded()
        layoutShapeLayers()
        super.layoutSubviews()
    }
    
    // MARK - Private
    
    private struct Key {
        static var strokeStart = "strokeStart"
        static var strokeEnd = "strokeEnd"
    }
    
    private struct Consts {
        static var hamburgerStrokeStart: CGFloat = 0.028
        static var closeStrokeStart: CGFloat = 0.325
        static var hamburgerStrokeEnd: CGFloat = 0.111
        static var closeStrokeEnd: CGFloat = 0.91
    }
    
    private lazy var top = CAShapeLayer()
    private lazy var mid = CAShapeLayer()
    private lazy var btm = CAShapeLayer()
    private var padding: CGFloat = 10
    private var lineWidth: CGFloat = 4
    private var initialSetupNeeded = true
    
    private func initialSetupIfNeeded() {
        guard initialSetupNeeded else {
            return
        }
        initialSetupNeeded = false
        //top.anchorPoint = CGPoint(x: 1, y: 0.5)
        allShapeLayers().forEach {
            self.layer.addSublayer($0)
            self.applyDefaults(to: $0)
        }
        mid.strokeStart = strkStart(progress == 0 ? .hamburger : .close)
        mid.strokeEnd = strkEnd(progress == 0 ? .hamburger : .close)
    }
    
    private func allShapeLayers() -> [CAShapeLayer] {
        return [mid, top, btm]
    }
    
    private func update(to progress: CGFloat) {
        if mid.animationKeys()?.count ?? 0 == 0 {
            mid.timeOffset = 0
            mid.strokeEnd == strkEnd(.hamburger) ? animateTo(.close) : animateTo(.hamburger)
            mid.speed = 0
        } else if mid.speed == 0 {
            mid.timeOffset = CFTimeInterval(progress * 0.6)
        }
    }
    
    private func strkStart(_ mode: Mode) -> CGFloat {
        return mode == .hamburger ? Consts.hamburgerStrokeStart : Consts.closeStrokeStart
    }
    
    private func strkEnd(_ mode: Mode) -> CGFloat {
        return mode == .hamburger ? Consts.hamburgerStrokeEnd : Consts.closeStrokeEnd
    }
    
    private func layoutShapeLayers() {
        padding = 0.05 * bounds.width
        let frame = self.bounds.insetBy(dx: padding, dy: padding)
        let midBounds = CGRect(origin: .zero, size: frame.size)
        lineWidth = 0.05769230769 * midBounds.width
        allShapeLayers().forEach {
            $0.lineWidth = self.lineWidth
        }
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
        // Cumpute line path
        let lineLength = 0.4815 * w
        let topLineY = 0.3333333333 * h
        let lineBounds = CGRect(origin: .zero, size: CGSize(width: lineLength + lineWidth * 2, height: lineWidth))
        let linePath = CGMutablePath()
        linePath.move(to: CGPoint(x: lineWidth, y: lineBounds.midY))
        linePath.addLine(to: CGPoint(x: lineLength + lineWidth, y: lineBounds.midY))
        // Top layer
        top.bounds = lineBounds
        top.position = CGPoint(x: frame.midX, y: frame.minY + topLineY)
        top.path = linePath
        // Bottom layer
        btm.bounds = lineBounds
        btm.position = CGPoint(x: frame.midX, y: frame.maxY - topLineY)
        btm.path = linePath
    }
    
    private func updateTintColor() {
        allShapeLayers().forEach {
            $0.strokeColor = tintColor.cgColor
        }
    }
    
    private func applyDefaults(to layer: CAShapeLayer) {
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = lineWidth
        layer.lineCap = kCALineCapRound
        layer.strokeColor = self.tintColor.cgColor
        layer.actions = ["strokeStart": NSNull(),
                         "strokeEnd": NSNull(),
                         "transform": NSNull()]
    }
}

extension CALayer {
    
    func applyAnimation(_ animation: CABasicAnimation) {
        guard let copy = animation.copy() as? CABasicAnimation,
            let keyPath = copy.keyPath else {
                return
        }
        if copy.fromValue == nil {
            copy.fromValue = self.presentation()?.value(forKeyPath: keyPath)
        }
        self.add(copy, forKey: copy.keyPath)
        self.setValue(copy.toValue, forKeyPath:copy.keyPath!)
    }
}

extension CABasicAnimation {
    
    convenience init(_ keyPath: String, toVal: Any?, duration: TimeInterval) {
        self.init(keyPath: keyPath)
        self.toValue = toVal
        self.duration = duration
        self.isRemovedOnCompletion = true
    }
}
