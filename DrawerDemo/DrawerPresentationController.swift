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
    
    /// `containerView` is optional for some reason. In case it is nil use 
    /// presenting controllers bounds
    private var containerBounds: CGRect {
        return containerView?.bounds ?? presentingViewController.view.bounds
    }
    
    /// Shadow chrome for drawer
    private weak var gradientView: GradientView?
    
    // MARK: - Transitioning
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard displayMode == .drawer else {
            return containerBounds
        }
        var frame = containerBounds
        frame.origin.x = frame.width * 0.117
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
    
    // MARK: -
    
    /// Animates presented viewcontroller's view to frame for `displayMode`.
    /// Tries to animate along`presentedViewController.transitionCoordinator`
    private func updateLayout(for displayMode: DrawerPresentationControllerDisplayMode) {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { (context) in
                self.presentedViewController.view.frame = self.frameOfPresentedViewInContainerView
            }, completion: nil)
        }
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.6, options: [.allowAnimatedContent, .layoutSubviews], animations: {
            self.presentedViewController.view.frame = self.frameOfPresentedViewInContainerView
        }, completion: nil)
    }
    
    /// Colors for more concentrated gradient
    private class func concentratedShadowColors() -> [UIColor] {
        let colors = (0..<2).map { _ in UIColor.black.withAlphaComponent(0) }
        return colors + [UIColor.black.withAlphaComponent(0.25)]
    }

}
