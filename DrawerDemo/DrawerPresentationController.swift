//
//  DrawerPresentationController.swift
//  DrawerDemo
//
//  Created by Michael Inger on 15/08/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit

class DrawerPresentationController: UIPresentationController {

    override var frameOfPresentedViewInContainerView: CGRect {
        var frame = containerView?.bounds ?? presentingViewController.view.bounds
        frame.origin.x = frame.width * 0.10
        frame.size.width -= frame.origin.x
        return frame
    }
    
}
