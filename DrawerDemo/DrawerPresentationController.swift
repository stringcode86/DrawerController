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

/// Presents viewcontroller as "drawer", adds show chrome
class DrawerPresentationController: UIPresentationController {
    
    /// Animates contained view from and to `.fullScreen` `.drawer` mode.
    var displayMode: DrawerPresentationControllerDisplayMode = .drawer {
        didSet {
            if oldValue != displayMode {
                updateLayout(for: displayMode)
            }
        }
    }
    
    private(set) weak var chromePanGestureRecognizer: UIPanGestureRecognizer?
    
    /// `containerView` is optional for some reason. In case it is nil use 
    /// presenting controllers bounds
    private var containerBounds: CGRect {
        return containerView?.bounds ?? presentingViewController.view.bounds
    }
    
    /// Shadow chrome for drawer
    private weak var gradientView: UIView? // GradientView?
    
    // MARK: - Transitioning
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard displayMode == .drawer else {
            return containerBounds
        }
        var frame = containerBounds
        frame.origin.x = round(frame.width * 0.117)
        frame.size.width -= frame.origin.x
        return frame
    }
    
    private var frameOfPresentedGradientViewInContainerView: CGRect {
        var frame = containerBounds
        frame.size.width = frameOfPresentedViewInContainerView.origin.x
        return frame
    }
    
    override func presentationTransitionWillBegin() {
        // Computer frames
        var startFrame = containerBounds
        startFrame.size.width = presentedViewController.view.frame.maxX
        let endFrame = frameOfPresentedGradientViewInContainerView
        //Create gradient view
        let gradientView = GradientView(frame: startFrame)
        gradientView.alpha = 0
        gradientView.colors = DrawerPresentationController.concentratedShadowColors()
        gradientView.direction = .horizontal
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        containerView?.addSubview(gradientView)
        self.gradientView = gradientView
        // Add pangesture recognizer
        let recognizer = UIPanGestureRecognizer()
        gradientView.addGestureRecognizer(recognizer)
        self.chromePanGestureRecognizer = recognizer
        // Animate
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            gradientView.alpha = 1
            gradientView.colors = GradientView.defaultShadowColors()
            gradientView.frame = endFrame
        }, completion: { finished in
            self.setupGradientViewConstraints()
        })
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if completed == false {
            gradientView?.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        let gradientView = self.gradientView
        containerView?.setNeedsLayout()
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            gradientView?.alpha = 0
            self.containerView?.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: -
    
    /// Animates presented viewcontroller's view to frame for `displayMode`.
    /// Tries to animate along`presentedViewController.transitionCoordinator`
    private func updateLayout(for displayMode: DrawerPresentationControllerDisplayMode) {
        let viewFrame = frameOfPresentedViewInContainerView
        let gradientFrame = frameOfPresentedGradientViewInContainerView
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { (context) in
                self.presentedView?.frame = viewFrame
                self.gradientView?.frame = gradientFrame
            }, completion: nil)
        }
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.6, options: [.allowAnimatedContent, .layoutSubviews], animations: {
            self.presentedView?.frame = viewFrame
            self.gradientView?.frame = gradientFrame
        }, completion: nil)
    }
    
    private func setupGradientViewConstraints() {
        guard let presentedView = self.presentedView, let gradientView = gradientView else {
            return
        }
        let views = ["gradientView": gradientView, "view": presentedView]
        let constsH = NSLayoutConstraint.constraints("H:|-0-[gradientView]-0-[view]", views: views)
        let constsV = NSLayoutConstraint.constraints("V:|-0-[gradientView]-0-|", views: views)
        self.containerView?.addConstraints(constsH + constsV)
    }
    
    /// Colors for more concentrated gradient
    private class func concentratedShadowColors() -> [UIColor] {
        let colors = (0..<2).map { _ in UIColor.black.withAlphaComponent(0) }
        return colors + [UIColor.black.withAlphaComponent(0.25)]
    }
}
