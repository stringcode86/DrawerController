//
//  OTRSplitViewController.swift
//  DrawerDemo
//
//  Created by Michael Inger on 15/08/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit

@objc protocol DrawerControllerDelegate: class {
    @objc optional func drawerControllerWillBeginInteractiveTransition(dc: DrawerController)
    @objc optional func drawerController(dc: DrawerController, didUpdateInteractiveTransition progress: CGFloat)
    @objc optional func drawerController(dc: DrawerController, didEndInteractiveTransition success: Bool)
}

/// `DrawerController` is container controller. Mimics conventions established 
/// by `UISplitViewController`. It displays two `UIViewController`s. `master` is
/// the one always visible and retained by `DrawerController` up until the point
/// where it is replaced. `drawer` in not retained. It is released imediatly 
/// after it is dismissed.
///
/// `DrawerController` navigation. Master presented as `childViewController`.
/// previous one is discarded. Drawer is presented modaly using custom
/// `DrawerPresentationController`.
///
/// - NOTE: See comment above `master` and `drawer` for details about navigation.
/// - NOTE: Unlike in `UISplitViewController`, `master` is the vc always visible.
/// In `UISplitviewController` master is on the side. (Hidden in portrait)
class DrawerController: UIViewController {
    
    /// **Master** can be set using `show(_:sender:)`. This causes `Drawer` 
    /// controller to replace current master view controller. Or using embed 
    /// segue from storyboard. Be sure to remove default `UIViewController.view`
    /// and replace it with embed view.
    private(set) weak var master: UIViewController?
    
    /// **Drawer** can shown using `showDrawerViewController(_:sender:)`. Or 
    /// using `ShowInDrawerSegue`.
    /// - NOTE: Once drawer is dismissed using `hideDrawerAction(_ sender: Any?)`
    /// or dismiss(animated:completion:). No strong references are retained.
    private(set) weak var drawer: UIViewController?
    
    /// Custom `UIPresentationController` that handles `drawer` presentation.
    fileprivate let drawerTransitioningDelegate = DrawerTransitioningDelegate()
    
    /// Changes presentaton to `.drawer` or `.fullScreen`. Automatically resets 
    /// to .drawer after `drawer` is dismissed
    var displayMode: DrawerPresentationControllerDisplayMode = .drawer {
        didSet {
            let vc = drawer?.presentationController as? DrawerPresentationController
            vc?.displayMode = displayMode
        }
    }

    @IBOutlet weak var delegate: DrawerControllerDelegate?
    
    /// Replaces current `master` with `vc`
    override func show(_ vc: UIViewController, sender: Any?) {
        // Remove current master
        master?.willMove(toParentViewController: nil)
        master?.view.removeFromSuperview()
        master?.removeFromParentViewController()
        // Add new master
        self.addChildViewController(vc)
        vc.view.frame = view.bounds
        self.view.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
        master = vc
    }
    
    /// This method will show a view controller within the semantic "drawer" UI
    /// associated with the current size-class environment. It's implementation
    /// calls `targetViewController(forAction:sender:)` first and redirects
    /// accordingly if the return value is not `self`, otherwise it will present
    /// the vc.
    override func showDrawerViewController(_ vc: UIViewController, sender: Any?) {
        self.drawer?.dismiss(animated: true)
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = drawerTransitioningDelegate
        present(vc, animated: true) { [weak self] in
            self?.setupDismissRecognizer()
        }
        drawer = vc
    }
    
    /// Dismissed `drawer`
    @IBAction func hideDrawerAction(_ sender: Any? ) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupDismissRecognizer() {
        let pan = (drawer?.presentationController as? DrawerPresentationController)?.chromePanGestureRecognizer
        pan?.addTarget(self, action: #selector(handleDismissPan(_:)))
    }
    
    override func targetViewController(forAction action: Selector, sender: Any?) -> UIViewController? {
        let customActions = [#selector(show(_:sender:)), #selector(showDrawerViewController(_:sender:))]
        if customActions.contains(action)  {
            return self
        }
        return super.targetViewController(forAction: action, sender: sender)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        displayMode = .drawer
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // NOTE:If there is no master and drawer that assume this is initial
        // embed segue from story board
        if segue.source == self && master == nil && drawer == nil {
            master = segue.destination
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        master?.view.frame = view.bounds
    }
    
    override func viewDidLayoutSubviews() {
        master?.view.frame = view.bounds
        super.viewDidLayoutSubviews()
    }
}

// MARK: - Handeling interactive transition

extension DrawerController {
    
    func prepareForInteractivePresentation() {
        delegate?.drawerControllerWillBeginInteractiveTransition?(dc: self)
        let animator = DrawerAnimator(direction: .right, isPresentation: true)
        drawerTransitioningDelegate.interactiveTransitioning = animator
    }
    
    func handlePresentationPan(_ recognizer: UIPanGestureRecognizer) {
        handleTransitionPan(recognizer, presentation: true)
    }
    
    /// Set this as target of `UIPanGestureRecognizer` that should drive dismiss
    /// interactive transitioning. Do not call dismiss, just add this as target.
    func handleDismissPan(_ recognizer: UIPanGestureRecognizer) {
        handleTransitionPan(recognizer)
    }
    
    private func handleTransitionPan(_ recognizer: UIPanGestureRecognizer, presentation: Bool = false) {
        let transitioning = drawerTransitioningDelegate.interactiveTransitioning
        let view: UIView = transitioning?.latestContainerView ?? self.view
        let translation = recognizer.translation(in: view)
        var progress: CGFloat = (translation.x / (view.bounds.width * 2))
        progress = min(max(presentation ? -progress : progress, 0.0), 1.0)
        switch recognizer.state {
        case .began:
            // Only setup for dismiss transition
            if presentation == false {
                delegate?.drawerControllerWillBeginInteractiveTransition?(dc: self)
                let animator = DrawerAnimator(direction: .right, isPresentation: false)
                drawerTransitioningDelegate.interactiveTransitioning = animator
                dismiss(animated: true)
            }
        case .changed:
            transitioning?.update(progress)
            delegate?.drawerController?(dc: self, didUpdateInteractiveTransition: progress)
        case .cancelled:
            transitioning?.cancel()
            delegate?.drawerController?(dc: self, didEndInteractiveTransition: false)
            drawerTransitioningDelegate.interactiveTransitioning = nil
        case .ended:
            let cancel = progress < 0.15
            cancel ? transitioning?.cancel() : transitioning?.finish()
            delegate?.drawerController?(dc: self, didEndInteractiveTransition: !cancel)
            drawerTransitioningDelegate.interactiveTransitioning = nil
        default: ()
        }
    }
}


// MARK: - DrawerController UIViewController extension

/// `UIViewController` extension that adds `DrawerController` support similiar
/// to `UINavigationController` or `UISplitViewController`. Also adds navigation
/// action `showDrawerViewController(_:sender:)` akin to 
/// `showDetailViewController(_:sender:)`
extension UIViewController {

    /// If this view controller has been pushed onto a drawer controller, return it.
    var drawerController: DrawerController? {
        return findParentDrawer(self)
    }
    
    private func findParentDrawer( _ vc: UIViewController?) -> DrawerController? {
        // Look for `DrawerController` in parents
        if let parent = vc?.parent {
            return (parent as? DrawerController) ?? parent.drawerController
        }
        // Check wether presenting is `DrawerController`
        if let drawer = vc?.presentingViewController as? DrawerController {
            return drawer
        }
        // Look for `DrawerController` in presenting VC parents
        return vc?.presentingViewController?.drawerController
    }
    
    /// This method will show a view controller within the semantic "drawer" UI 
    /// associated with the current size-class environment. It's implementation 
    /// calls `targetViewController(forAction:sender:)` first and redirects 
    /// accordingly if the return value is not `self`, otherwise it will present 
    /// the vc.
    func showDrawerViewController(_ vc: UIViewController, sender: Any?) {
        let selector = #selector(showDetailViewController(_:sender:))
        let handler = targetViewController(forAction: selector, sender: sender)
        if let handler = handler, handler != self {
                handler.showDrawerViewController(vc, sender: sender)
        }
        present(vc, animated: true, completion: nil)
    }
}

// MARK: - ShowInDrawerSegue

/// Custom segues that shows destination VC in the `UIDrawerController.drawer`.
class ShowInDrawerSegue: UIStoryboardSegue {
    
    override func perform() {
        source.showDrawerViewController(destination, sender: self)
    }
}
