//
//  UIViewController+Extensions.swift
//  TestNotificationContent
//
//  Created by Dmitry Grigoryev on 19.06.2021.
//

import UIKit

extension UIViewController {
    
    func removePreviousViewsAndAdd(view: UIView?) {
        guard let view = view else {return}
        self.view.subviews.forEach{$0.removeFromSuperview()}
        self.view.addSubview(view)
        
        NSLayoutConstraint.activate([
            self.view.topAnchor.constraint(equalTo: view.topAnchor),
            self.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            self.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
}
