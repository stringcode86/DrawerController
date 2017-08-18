//
//  HamburgerButton.swift
//  DrawerDemo
//
//  Created by Michael Inger on 18/08/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit

/// `HamburgerButton` display button with "Hamburger" or "Close" icon. Support
/// interactive transition via `transitionProgress` property. After interactive
/// transition animateTo(_:) should be called with desired end state.
class HamburgerButton: UIButton {
    
    lazy var hamburgerView: HamburgerView = HamburgerView()
    
    /// Returns mode based on current UI state
    var mode: HamburgerView.Mode {
        return hamburgerView.mode
    }
    
    /// Used for interctive transition between modes. Automatical switches to
    /// oposite mode when value is set. ie if its in `.hamberger` transitions to
    /// `.close`. Accepts values from 0 to 1.
    /// - NOTE: After interactive transition animateTo(_:) should be called 
    /// with desired end state.
    var transitionProgress: CGFloat {
        get {
            return hamburgerView.progress
        }
        set {
            hamburgerView.progress = newValue
        }
    }
    
    /// Animates button icon to given `mode`.
    func animateTo(_ mode: HamburgerView.Mode) {
        print("anim \(hamburgerView)")
        hamburgerView.animateTo(mode)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    private func initialSetup() {
        hamburgerView.isUserInteractionEnabled = false
        addSubview(hamburgerView)
    }

    override func layoutSubviews() {
        let width = min(bounds.width, bounds.height)
        let hBounds = CGRect(origin: .zero, size: CGSize(width: width, height: width))
        hamburgerView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        hamburgerView.bounds = hBounds
        super.layoutSubviews()
    }

}

