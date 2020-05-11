//
//  GradientView.swift
//  DrawerDemo
//
//  Created by Michael Inger on 16/08/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit

/// Convenience `UIView` wrapper for `CAGradientLayer`. Main goal to easily show
/// stuble shadows without having to add assets to the app. `UIView` wrapper 
/// is handy as it avoids having to deal with more cumbersome `CALayer` layout
class GradientView: UIView {
    
    enum Direction {
        case horizontal
        case vertical
        case custom(CGPoint, CGPoint)
    }
    
    /// Defining the color of each gradient * stop. Defaults to nil. Animatable.
    var colors: [UIColor] {
        get {
            let cgColors = (layer as? CAGradientLayer)?.colors as? [CGColor]
            return cgColors?.compactMap { UIColor(cgColor: $0) } ?? []
        }
        set {
            (layer as? CAGradientLayer)?.colors = newValue.map { $0.cgColor }
        }
    }
    
    /// Defines direction of gradient in `CAGradientLayer`
    var direction: Direction = .horizontal {
        didSet {
            switch direction {
            case .horizontal:
                (layer as? CAGradientLayer)?.startPoint = CGPoint(x: 0, y: 0.5)
                (layer as? CAGradientLayer)?.endPoint = CGPoint(x: 1, y: 0.5)
            case .vertical:
                (layer as? CAGradientLayer)?.startPoint = CGPoint(x: 0, y: 0)
                (layer as? CAGradientLayer)?.endPoint = CGPoint(x: 0, y: 1)
            case .custom(let startPoint, let endPoint):
                (layer as? CAGradientLayer)?.startPoint = startPoint
                (layer as? CAGradientLayer)?.endPoint = endPoint
            }
        }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    /// two black colors with aplha at 0 and 0.25
    class func defaultShadowColors() -> [UIColor] {
        return [UIColor.black.withAlphaComponent(0), UIColor.black.withAlphaComponent(0.25)]
    }
}
