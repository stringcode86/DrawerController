//
//  OTRSplitViewController.swift
//  DrawerDemo
//
//  Created by Michael Inger on 15/08/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit

class DrawerController: UIViewController {
    
    private(set) weak var master: UIViewController?
    private(set) weak var drawer: UIViewController?
    
    @IBAction func hideDrawerAction(_ sender: Any? ) {
        dismiss(animated: true, completion: nil)
    }
        
    override func targetViewController(forAction action: Selector, sender: Any?) -> UIViewController? {
        let customActions = [#selector(show(_:sender:)), #selector(showDrawerViewController(_:sender:))]
        if customActions.contains(action)  {
            return self
        }
        return super.targetViewController(forAction: action, sender: sender)
    }
    
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
    
    override func showDrawerViewController(_ vc: UIViewController, sender: Any?) {
        present(vc, animated: true, completion: nil)
        drawer = vc
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // NOTE:If there is no master and drawer that assume this is initial
        // embed segue from story board
        if segue.source == self && master == nil && drawer == nil {
            master = segue.destination
        }
    }
    
    override func viewWillLayoutSubviews() {
        master?.view.frame = view.bounds
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        master?.view.frame = view.bounds
        super.viewDidLayoutSubviews()
    }
    
}

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
    /// associated with the current size-class environment. It's implementation calls
    /// `[self targetViewControllerForAction:sender:]` first and redirects accordingly
    /// if the return value is not `self`, otherwise it will present the vc.
    func showDrawerViewController(_ vc: UIViewController, sender: Any?) {
        let selector = #selector(showDetailViewController(_:sender:))
        let handler = targetViewController(forAction: selector, sender: sender)
        if let handler = handler, handler != self {
                handler.showDrawerViewController(vc, sender: sender)
        }
        present(vc, animated: true, completion: nil)
    }
}


class ShowInDrawer: UIStoryboardSegue {
    
    override func perform() {
        source.showDrawerViewController(destination, sender: self)
    }
}
