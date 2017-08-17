//
//  NSLayoutConstraint+Extensions.swift
//  DrawerDemo
//
//  Created by Michael Inger on 17/08/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    
    class func constraintsToCoverSuperview(for view: UIView) -> [NSLayoutConstraint] {
        let views = ["view": view]
        let constsH = NSLayoutConstraint.constraints("H:|-0@1000-[view]-0@1000-|", views: views)
        let constsV = NSLayoutConstraint.constraints("V:|-0@1000-[view]-0@100-|", views: views)
        return constsH + constsV
    }
    
    class func constraints(_ visualFormat: String, views: [String: Any]) -> [NSLayoutConstraint] {
        return self.constraints(withVisualFormat: visualFormat, options: [], metrics: nil, views: views)
    }
}
