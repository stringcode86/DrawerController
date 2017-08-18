//
//  DrawerViewController.swift
//  DrawerDemo
//
//  Created by Michael Inger on 15/08/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit

class DrawerViewController: UIViewController, DrawerControllerDelegate {

    @IBOutlet weak var hamburgerButton: HamburgerButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawerController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        drawerController?.displayMode = .drawer
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hamburgerButton.animateTo(.close)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        drawerController?.displayMode = .fullScreen
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        drawerController?.displayMode = .fullScreen
    }
    
    // MARK: - Actions
    
    @IBAction func hideDrawer(_ sender: Any) {
        hamburgerButton.animateTo(.hamburger)
        drawerController?.hideDrawerAction(self)
    }
    
    @IBAction func toggleAction(_ sender: Any) {
        guard let displayMode = drawerController?.displayMode else {
            return
        }
        drawerController?.displayMode = displayMode == .drawer ? .fullScreen : .drawer
    }
    
    // MARK: DrawerControllerDelegate 
    
    func drawerControllerWillBeginInteractiveTransition(dc: DrawerController) { }
    
    func drawerController(dc: DrawerController, didUpdateInteractiveTransition progress: CGFloat) {
        hamburgerButton.transitionProgress = progress * 3
    }
    
    func drawerController(dc: DrawerController, didEndInteractiveTransition success: Bool) {
        hamburgerButton.animateTo(success ? .hamburger : .close)
    }
    
    // MARK: - Debug
    
    @IBAction func sliderAction(_ sender: UISlider) {
        hamburgerButton.transitionProgress = CGFloat(sender.value)
    }
    
    @IBAction func animateToHamburger(_ sender: Any) {
        hamburgerButton.animateTo(.hamburger)
    }
    
    @IBAction func animateToClose(_ sender: Any) {
        hamburgerButton.animateTo(.close)
    }
    
    
}
