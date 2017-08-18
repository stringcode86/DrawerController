//
//  HamburgerView.swift
//  DrawerDemo
//
//  Created by Michael Inger on 17/08/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit


/// `HamburgerView` draws hamburger and close icons at any scale. Supports
/// animating and interactiver transition from one to another.
/// NOTE: Curently underdeveloped only implement features necessary for 
/// use with `DrawerController`
@IBDesignable class HamburgerView: UIView, CAAnimationDelegate {
    
    enum Mode {
        case hamburger
        case close
    }
    
    /// Returns mode based on current UI state
    var mode: Mode {
        return mid.strokeEnd == strkEnd(.hamburger) ? .hamburger : .close
    }
    
    /// Used for interctive transition between modes. Automatical switches to 
    /// oposite mode when value is set. ie if its in `.hamberger` transitions to
    /// `.close`. Accepts values from 0 to 1.
    /// - NOTE: After interactive transition animateTo(_:) should be called
    /// with desired end state.
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
    
    /// Animates to given `mode`.
    func animateTo(_ mode: HamburgerView.Mode) {
        // Create animations
        let strokeStart = CABasicAnimation(Key.strokeStart, toVal: strkStart(mode), duration: 0.5)
        let strokeEnd   = CABasicAnimation(Key.strokeEnd, toVal: strkEnd(mode), duration: 0.6)
        let tTransform  = CABasicAnimation(Key.transform, toVal: transform(mode), duration: 0.4)
        strokeStart.timingFunction = Consts.strokeTiming
        strokeEnd.timingFunction   = Consts.strokeTiming
        tTransform.timingFunction  = Consts.lineTiming
        let bTransform = tTransform.copy(withToValue: transform(mode, top: false))
        // If speed is 0 that means animating after interactive progress transition
        // In that case animation from curent presentation layer value
        if mid.speed == 0 {
            strokeStart.fromValue = mid.presentation()?.value(forKeyPath: Key.strokeStart)
            strokeEnd.fromValue = mid.presentation()?.value(forKeyPath: Key.strokeEnd)
            tTransform.fromValue = top.presentation()?.value(forKeyPath: Key.transform)
            bTransform.fromValue = btm.presentation()?.value(forKeyPath: Key.transform)
            allShapeLayers().forEach {
                $0.timeOffset = $0.beginTime + Date().timeIntervalSince1970
                $0.speed = 1
            }
        }
        strokeEnd.delegate = self
        allShapeLayers().forEach { $0.removeAllAnimations() }
        [strokeStart, strokeEnd].forEach { mid.applyAnimation($0) }
        top.applyAnimation(tTransform)
        btm.applyAnimation(bTransform)
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
        static var transform = "transform"
    }
    
    private struct Consts {
        static var hamburgerStrokeStart: CGFloat = 0.028
        static var closeStrokeStart: CGFloat = 0.325
        static var hamburgerStrokeEnd: CGFloat = 0.111
        static var closeStrokeEnd: CGFloat = 0.91
        static var translationRatio: CGFloat = -0.076923
        static var strokeTiming = CAMediaTimingFunction(controlPoints: 0.25, -0.4, 0.5, 1)
        static var lineTiming = CAMediaTimingFunction(controlPoints: 0.5, -0.8, 0.5, 1.85)
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
        allShapeLayers().forEach {
            self.layer.addSublayer($0)
            self.applyDefaults(to: $0)
        }
        allLineLayers().forEach {
            $0.anchorPoint = CGPoint(x: 1, y: 0.5)
        }
        mid.strokeStart = strkStart(progress == 0 ? .hamburger : .close)
        mid.strokeEnd = strkEnd(progress == 0 ? .hamburger : .close)
    }
    
    /// If there is not animation present, creates animation and sets layers
    /// `speed` to 0. Then manipulates `timeOffSet` to update presentation layer
    private func update(to progress: CGFloat) {
        if mid.animationKeys()?.count ?? 0 == 0 {
            allShapeLayers().forEach { $0.timeOffset = 0 }
            mid.strokeEnd == strkEnd(.hamburger) ? animateTo(.close) : animateTo(.hamburger)
            allShapeLayers().forEach { $0.speed = 0 }
        } else if mid.speed == 0 {
            allShapeLayers().forEach { $0.timeOffset = $0.beginTime + CFTimeInterval(progress * 0.6) }
        }
    }
    
    private func transform(_ mode: Mode, top: Bool = true) -> NSValue {
        let transX = Consts.translationRatio * bounds.width
        let angle = CGFloat.pi / 4
        let translation = CATransform3DMakeTranslation(transX, 0, 0)
        let rotation = CATransform3DRotate(translation, angle, 0, 0, top ? -1 : 1)
        return NSValue(caTransform3D: mode == .close ? rotation : CATransform3DIdentity )
    }
    
    private func strkStart(_ mode: Mode) -> CGFloat {
        return mode == .hamburger ? Consts.hamburgerStrokeStart : Consts.closeStrokeStart
    }
    
    private func strkEnd(_ mode: Mode) -> CGFloat {
        return mode == .hamburger ? Consts.hamburgerStrokeEnd : Consts.closeStrokeEnd
    }
    
    /// I appologies to anyone who has to look at this code let alone edit it
    /// It super messy. What it achieves is button is correctly drawn relatively
    /// bounds at any bouns.
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
        let lineBounds = CGRect(origin: .zero, size: CGSize(width: lineLength + (0 * 2), height: lineWidth))
        let linePath = CGMutablePath()
        linePath.move(to: CGPoint(x: 0, y: lineBounds.midY))
        linePath.addLine(to: CGPoint(x: lineLength + 0, y: lineBounds.midY))
        // Top layer
        top.bounds = lineBounds
        top.position = CGPoint(x: frame.midX + (lineLength * 0.5) + 0, y: frame.minY + topLineY)
        top.path = linePath
        // Bottom layer
        btm.bounds = lineBounds
        btm.position = CGPoint(x: frame.midX + (lineLength * 0.5) + 0, y: frame.maxY - topLineY)
        btm.path = linePath
    }
    
    private func updateTintColor() {
        allShapeLayers().forEach {
            $0.strokeColor = tintColor.cgColor
        }
    }
    
    private func allShapeLayers() -> [CAShapeLayer] {
        return [mid, top, btm]
    }
    
    private func allLineLayers() -> [CAShapeLayer] {
        return [top, btm]
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
    
    /// HACK: to avoid issues with animations not being removed on completions
    /// https://stackoverflow.com/questions/12798207/unpredictable-behavior-with-core-animation-cabasicanimation
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            allLineLayers().forEach {
                $0.removeAllAnimations()
                $0.setNeedsDisplay()
            }
        }
    }
}

// MARK: - CALayer extensions

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

// MARK: - CABasicAnimation extensions

extension CABasicAnimation {
    
    convenience init(_ keyPath: String, toVal: Any?, duration: TimeInterval) {
        self.init(keyPath: keyPath)
        self.toValue = toVal
        self.duration = duration
        self.isRemovedOnCompletion = true
        self.fillMode = kCAFillModeBoth
    }
    
    func copy(withToValue val: Any?) -> CABasicAnimation {
        let anim = self.copy() as! CABasicAnimation
        anim.toValue = val
        return anim
    }
}
