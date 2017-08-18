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
    
    var interactiveTransitioning: DrawerAnimator?
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DrawerPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DrawerAnimator(direction: .right, isPresentation: true)
        
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DrawerAnimator(direction: .right, isPresentation: false)
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransitioning
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransitioning
    }
}

// MARK: - DrawerAnimator

final class DrawerAnimator: UIPercentDrivenInteractiveTransition {
    
    enum PresentationDirection {
        case left
        case top
        case right
        case bottom
    }
    
    let direction: PresentationDirection
    let isPresentation: Bool
    
    /// Used for handeling of gesture reconizer (progress copuation)
    weak var latestContainerView: UIView?
    
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
        self.latestContainerView = transitionContext.containerView
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
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.6, options: [.beginFromCurrentState, .allowAnimatedContent], animations: {
            controller.view.frame = finalFrame
        }) { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
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

// MARK - UIViewControllerInteractiveTransitioning

extension DrawerAnimator {

    func handleDismissPan(_ recognizer: UIPanGestureRecognizer) {
        // Trying to presist referect to container view form transition context
        // animation. This should succeed every time. Otherwise fall back to
        // gesture recognizer view
        guard let view = latestContainerView ?? recognizer.view else {
            return
        }
        // Dont want to be switing to the views as its transition is calculated
        // based on them. So preserve the view that was set first
        latestContainerView = view
        let translation = recognizer.translation(in: view)
        var progress = (translation.x / (view.bounds.width * 2))
        progress = min(max(progress, 0.0), 1.0)
        
        switch recognizer.state {
        case .changed:
            update(progress)
        case .cancelled:
            cancel()
        case .ended:
            if progress < 0.15 {
                cancel()
            } else {
                finish()
            }
        default: ()
        }
    }

}
