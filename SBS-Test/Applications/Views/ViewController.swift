//
//  ViewController.swift
//  SBS-Test
//
//  Created by Dmitry Grigoryev on 14.06.2021.
//

import UIKit

class ViewController: UIViewController {
    
    var coordinator: ApplePayCoordinate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .cyan
        self.coordinator = ApplePayCoordinate(ApplePayContent(title: "ApplePay"), in: self)
        coordinator?.start()
    }
    
}

