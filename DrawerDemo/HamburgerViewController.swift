//
//  HamburgerViewController.swift
//  DrawerDemo
//
//  Created by Michael Inger on 17/08/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {

    @IBOutlet weak var btnOne: HamburgerButton!
    @IBOutlet weak var btnTwo: HamburgerButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func btnOneAction(_ sender: Any) {
        
    }
    
    @IBAction func btnTwoAction(_ sender: Any) {
    
    }
    
    
    @IBAction func sliderAction(_ sender: UISlider) {
        btnOne.transitionProgress = CGFloat(sender.value)
        btnTwo.transitionProgress = CGFloat(sender.value)
    }
    
    
    @IBAction func animateAction(_ sender: Any) {
        btnOne.animateTo(.close)
        btnTwo.animateTo(.close)
    }
    
    @IBAction func animateToHamburgerAction(_ sender: Any) {
        btnOne.animateTo(.hamburger)
        btnTwo.animateTo(.hamburger)
    }
    
}
 
