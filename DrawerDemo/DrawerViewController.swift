//
//  DrawerViewController.swift
//  DrawerDemo
//
//  Created by Michael Inger on 15/08/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit

class DrawerViewController: UIViewController {

    @IBAction func hideDrawer(_ sender: Any) {
        drawerController?.hideDrawerAction(self)
    }
    
    
    @IBAction func toggleAction(_ sender: Any) {
        guard let displayMode = drawerController?.displayMode else {
            return
        }
        drawerController?.displayMode = displayMode == .drawer ? .fullScreen : .drawer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        drawerController?.displayMode = .drawer
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        drawerController?.displayMode = .fullScreen
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //drawerController?.displayMode = .fullScreen
    }
    
}
