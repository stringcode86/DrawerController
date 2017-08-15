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
}
