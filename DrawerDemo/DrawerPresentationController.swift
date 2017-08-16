//
//  DrawerPresentationController.swift
//  DrawerDemo
//
//  Created by Michael Inger on 15/08/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit

enum DrawerPresentationControllerDisplayMode {
    case drawer
    case fullScreen
}

class DrawerPresentationController: UIPresentationController {
    private weak var gradientView: GradientView?
    private var containerBounds: CGRect {
        return containerView?.bounds ?? presentingViewController.view.bounds
    }
    var displayMode: DrawerPresentationControllerDisplayMode = .drawer {
        didSet {
            if oldValue != displayMode {
                updateLayout(for: displayMode)
            }
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard displayMode == .drawer else {
            return containerBounds
        }
        var frame = containerBounds
        frame.origin.x = frame.width * 0.10
        frame.size.width -= frame.origin.x
        return frame
    }
    
    override func presentationTransitionWillBegin() {
        // Compute frames for `gradientView`
        var startFrame = containerBounds
        startFrame.size.width = presentedViewController.view.frame.maxX
        var endFrame = containerBounds
        endFrame.size.width = frameOfPresentedViewInContainerView.origin.x
        // Update view hierarchy
        let gradientView = GradientView(frame: startFrame)
        gradientView.alpha = 0
        gradientView.colors = DrawerPresentationController.concentratedShadowColors()
        gradientView.direction = .horizontal
        containerView?.addSubview(gradientView)
        self.gradientView = gradientView
        // Animate
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            gradientView.alpha = 1
            gradientView.colors = GradientView.defaultShadowColors()
            gradientView.frame = endFrame
        }, completion: nil)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if completed == false {
            gradientView?.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        let gradientView = self.gradientView
        let endFrame = containerBounds
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            gradientView?.alpha = 0
            gradientView?.frame = endFrame
        }, completion: nil)
    }
    
    private class func concentratedShadowColors() -> [UIColor] {
         return [UIColor.black.withAlphaComponent(0),
                 UIColor.black.withAlphaComponent(0),
                 UIColor.black.withAlphaComponent(0.25)]
    }
    
    func updateLayout(for displayMode: DrawerPresentationControllerDisplayMode) {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { (context) in
                self.presentedViewController.view.frame = self.frameOfPresentedViewInContainerView
            }, completion: nil)
        }
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.6, options: [.allowAnimatedContent, .layoutSubviews], animations: {
            self.presentedViewController.view.frame = self.frameOfPresentedViewInContainerView
        }, completion: nil)
    }

}


class GradientView: UIView {
    
    enum Direction {
        case horizontal
        case vertical
        case custom(CGPoint, CGPoint)
    }
    
    var colors: [UIColor] {
        get {
            let cgColors = (layer as? CAGradientLayer)?.colors as? [CGColor]
            return cgColors?.flatMap { UIColor(cgColor: $0) } ?? []
        }
        set {
            (layer as? CAGradientLayer)?.colors = newValue.map { $0.cgColor }
        }
    }
    
    var direction: Direction = .horizontal {
        didSet {
            switch direction {
            case .horizontal:
                (layer as? CAGradientLayer)?.startPoint = CGPoint(x: 0, y: 0.5)
                (layer as? CAGradientLayer)?.endPoint = CGPoint(x: 1, y: 0.5)
            case .vertical:
                (layer as? CAGradientLayer)?.startPoint = CGPoint(x: 0, y: 0)
                (layer as? CAGradientLayer)?.endPoint = CGPoint(x: 0, y: 1)
            case .custom(let startPoint, let endPoint):
                (layer as? CAGradientLayer)?.startPoint = startPoint
                (layer as? CAGradientLayer)?.endPoint = endPoint
            }
        }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    class func defaultShadowColors() -> [UIColor] {
        return [UIColor.black.withAlphaComponent(0), UIColor.black.withAlphaComponent(0.25)]
    }
}
