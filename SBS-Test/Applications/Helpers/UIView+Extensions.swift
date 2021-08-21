//
//  UIView+Extensions.swift
//  SBS-Test
//
//  Created by Dmitry Grigoryev on 21.08.2021.
//

import UIKit

extension UIView {
    func setBackgroundColor(color: Color) {
        switch color {
        case .Red:
            self.backgroundColor = UIColor.red
            break
        case .Green:
            self.backgroundColor = UIColor.green
            break
        case .Blue:
            self.backgroundColor = UIColor.blue
            break
        }
    }
    
    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: layer.bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: layer.bounds.size.height * layer.anchorPoint.y);

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = point
    }
}
