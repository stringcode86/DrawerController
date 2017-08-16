//
//  DrawerPresentationTransitioning.swift
//  DrawerDemo
//
//  Created by Michael Inger on 15/08/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit


/// This file contains standard custom iOS transitioning boiler plate madness.
/// Intendet to be used by `DrawerController` only

// MARK: - UIViewControllerTransitioningDelegate


class DrawerTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DrawerPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DrawerAnimator(direction: .right, isPresentation: true)
        
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DrawerAnimator(direction: .right, isPresentation: false)
    }
}

// MARK: - DrawerAnimator

final class DrawerAnimator: NSObject {
    
    enum PresentationDirection {
        case left
        case top
        case right
        case bottom
    }
    
    let direction: PresentationDirection
    let isPresentation: Bool
    
    init(direction: PresentationDirection, isPresentation: Bool) {
        self.direction = direction
        self.isPresentation = isPresentation
        super.init()
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension DrawerAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let key = isPresentation ? UITransitionContextViewControllerKey.to : UITransitionContextViewControllerKey.from
        let controller = transitionContext.viewController(forKey: key)!
        if isPresentation {
            transitionContext.containerView.addSubview(controller.view)
        }
        let presented = transitionContext.finalFrame(for: controller)
        let dismissed = self.dismissedFrame(presentedFrame: presented, context: transitionContext)
        let initialFrame = isPresentation ? dismissed : presented
        let finalFrame = isPresentation ? presented : dismissed
        let duration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.6, options: [], animations: {
            controller.view.frame = finalFrame
        }) { finished in
            transitionContext.completeTransition(finished)
        }
    }
    
    private func dismissedFrame(presentedFrame: CGRect, context: UIViewControllerContextTransitioning) -> CGRect {
        var dismissedFrame = presentedFrame
        switch direction {
        case .left:
            dismissedFrame.origin.x = -presentedFrame.width
        case .right:
            dismissedFrame.origin.x = context.containerView.frame.width
        case .top:
            dismissedFrame.origin.y = -presentedFrame.height
        case .bottom:
            dismissedFrame.origin.y = context.containerView.frame.height
        }
        return dismissedFrame
    }
}
