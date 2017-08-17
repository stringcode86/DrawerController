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
    
    
    @IBOutlet weak var hamburgerView1: HamburgerView!
    @IBOutlet weak var hamburgerView2: HamburgerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func btnOneAction(_ sender: Any) {
        btnOne.showsMenu = !btnOne.showsMenu
    }
    
    @IBAction func btnTwoAction(_ sender: Any) {
        btnTwo.showsMenu = !btnTwo.showsMenu
    }
    
    
    @IBAction func sliderAction(_ sender: UISlider) {
        hamburgerView1.progress = CGFloat(sender.value)
        hamburgerView2.progress = CGFloat(sender.value)
    }
    
    
    @IBAction func animateAction(_ sender: Any) {
        hamburgerView1.animateToClose()
        hamburgerView2.animateToClose()
    }
    
}
