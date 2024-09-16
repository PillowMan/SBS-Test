//
//  CATransform3D+Extensions.swift
//  SBS-Test
//
//  Created by Dmitry Grigoryev on 07.11.2021.
//

import UIKit

extension CATransform3D {
    public static var defaultTransform: CATransform3D {
        var transform = CATransform3DIdentity
            transform.m34 = -1/700
            return transform
    }
}
