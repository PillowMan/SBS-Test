//
//  UIViewControllers+Extensions.swift
//  SBS-Test
//
//  Created by Dmitry Grigoryev on 14.06.2021.
//

import UIKit

extension UIViewController {
    func configLayout(_ view: UIView){
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
        
        ])
    }
    
    func removePreviousViewsAndAdd(view: UIView?) {
        guard let view = view else {return}
        self.view.subviews.forEach{$0.removeFromSuperview()}
        self.view.addSubview(view)
        configLayout(view)
    }
}
