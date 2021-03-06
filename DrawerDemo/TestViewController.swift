//
//  TestViewController.swift
//  DrawerDemo
//
//  Created by Michael Inger on 15/08/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit



class TestViewController: UIViewController {
    
    @IBOutlet weak var humburgerButton: HamburgerButton?
    
    @IBAction func testOneAction(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "TestViewController")
        drawerController?.show(vc, sender: self)
        
    }
    
    @IBAction func testTwoAction(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "YellowViewController")
        show(vc, sender: self)
    }

    @IBAction func testThreeAction(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "RedViewController")
        drawerController?.show(vc, sender: self)
    }
    
    @IBAction func showDebugAction(_ sender: Any) {
        presentDebugOvelayView(self)
    }
    
    @IBAction func showDrawer(_ sender: Any) {
        //humburgerButton?.animateTo(.close)
        drawerController?.performSegue(withIdentifier: "showDrawer", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //humburgerButton?.animateTo(.hamburger)
        
    }
    
    @IBAction func rightEdgePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            drawerController?.prepareForInteractivePresentation()
            drawerController?.performSegue(withIdentifier: "showDrawer", sender: self)
        default:
            drawerController?.handlePresentationPan(sender)
        }
    }
}


// MARK: - Debugging Information Overlay Hack

// Enables Apple's debugging information overlay. Do not submit to AppStore!
// http://ryanipete.com/blog/ios/swift/objective-c/uidebugginginformationoverlay/
extension TestViewController {
    
    /// Performs bunch of hacks to get debugging info displayed
    @objc func presentDebugOvelayView(_ sender: Any?) {
        let overlayClass = NSClassFromString("UIDebuggingInformationOverlay") as? UIWindow.Type
        _ = overlayClass?.perform(NSSelectorFromString("prepareDebuggingOverlay"))
        let overlay = overlayClass?.perform(NSSelectorFromString("overlay")).takeUnretainedValue() as? UIWindow
        _ = overlay?.perform(NSSelectorFromString("toggleVisibility"))
    }
}
