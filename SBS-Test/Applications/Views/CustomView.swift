//
//  CustomView.swift
//  SBS-Test
//
//  Created by Dmitry Grigoryev on 21.08.2021.
//

import UIKit

class CustomView: UIView {

    var shadowLayer: CAShapeLayer?
    let cornerRadius: CGFloat = 15
    var fillColor: UIColor {get{return .cyan}}
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer!.fillColor = fillColor.cgColor
            shadowLayer!.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer?.lineWidth = 0.5
            shadowLayer!.strokeColor = UIColor.gray.cgColor
            shadowLayer!.shadowColor = UIColor.black.cgColor
            shadowLayer!.shadowPath = shadowLayer?.path
            shadowLayer!.shadowOffset = CGSize(width: 10, height: 10)
            shadowLayer!.shadowRadius = 5.0
            shadowLayer!.shadowOpacity = 0.1
            layer.insertSublayer(shadowLayer!, at: 0)
        }
    }
    
    func showShadow(show: Bool){
        shadowLayer?.shadowOpacity = show ? 0.1 : 0
    }

}

