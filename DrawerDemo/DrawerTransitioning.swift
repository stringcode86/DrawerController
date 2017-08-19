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
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.latestContainerView = transitionContext.containerView
        let key: UITransitionContextViewControllerKey = isPresentation ? .to : .from
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


// MARK: - PrivateAnimator 

/// Private transitioning animator, designed to be only used for `DrawerController`
/// `show(_:sender:)` transition.
class PrivateAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!
        let duration = transitionDuration(using: transitionContext)
        let container = transitionContext.containerView
        toVC.view.frame = transitionContext.initialFrame(for: toVC)
        container.addSubview(toVC.view)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.6, options: [], animations: {
            fromVC.view.frame = transitionContext.finalFrame(for: fromVC)
            toVC.view.frame = transitionContext.finalFrame(for: toVC)
        }) { finished in
            container.layer.sublayerTransform = CATransform3DIdentity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        add3DTransformAnimation(fromVC, container: container, duration: duration)
    }
    
    private func add3DTransformAnimation(_ toVC: UIViewController, container: UIView, duration: Double) {
        let key = "transform"
        container.layer.sublayerTransform = sublayerTransform()
        let anim = CABasicAnimation(key, toVal: fromVCTransform(), duration: duration * 0.6)
        anim.isRemovedOnCompletion = false
        toVC.view.layer.add(anim, forKey: key)
    }
    
    private func fromVCTransform() -> NSValue {
        var transform = CATransform3DMakeRotation(CGFloat.pi / 8, 1, 0, 0)
        transform = CATransform3DTranslate(transform, 0, -150, -150)
        return NSValue(caTransform3D: transform)
    }
    
    private func sublayerTransform() -> CATransform3D {
        var sublayerTransform = CATransform3DIdentity
        sublayerTransform.m34 = -1.0 / 1000
        return sublayerTransform
    }
}


// MARK: - PrivateTransitionContext

/// Private transitioning context, designed to be only used for `DrawerController`
/// `show(_:sender:)` transition.
class PrivateTransitionContext: NSObject, UIViewControllerContextTransitioning {
    let presentationStyle: UIModalPresentationStyle = .none
    let targetTransform: CGAffineTransform = .identity
    let isAnimated = true
    let isInteractive = false
    var transitionWasCancelled = false
    var completion: ((_ didComplete: Bool)->())?
    private(set) var containerView: UIView
    private var fromVC: UIViewController
    private var toVC: UIViewController
    
    init(fromVC: UIViewController, toVC: UIViewController) {
        self.containerView = fromVC.view.superview!
        self.fromVC = fromVC
        self.toVC = toVC
        super.init()
    }
    
    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        switch key {
        case UITransitionContextViewControllerKey.from : return fromVC
        case UITransitionContextViewControllerKey.to   : return toVC
        default: return nil
        }
    }
    
    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        switch key {
        case UITransitionContextViewKey.from : return fromVC.view
        case UITransitionContextViewKey.to   : return toVC.view
        default: return nil
        }
    }
    
    func initialFrame(for vc: UIViewController) -> CGRect {
        var frame = fromVC.view.frame
        frame.origin.y = containerView.bounds.maxY
        return vc == fromVC ? fromVC.view.frame : frame
    }
    
    func finalFrame(for vc: UIViewController) -> CGRect {
        return containerView.bounds
    }
    
    func completeTransition(_ didComplete: Bool) {
        completion?(didComplete)
    }

    /// Silencing unsuported interactive transion methods
    func updateInteractiveTransition(_ percentComplete: CGFloat) {}
    func finishInteractiveTransition() {}
    func cancelInteractiveTransition() {}
    func pauseInteractiveTransition() {}
}

