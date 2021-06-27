//
//  ApplePayCoordinate.swift
//  SBS-Test
//
//  Created by Dmitry Grigoryev on 20.06.2021.
//

import UIKit

class ApplePayCoordinate {
    
    let controller: ViewController
    let model: ApplePayContent
    init(_ model: ApplePayContent, in controller: ViewController) {
        self.model = model
        self.controller = controller
    }
    func start(){
        let viewModel = ApplePayViewModel(model)
        let view = ApplePayView()
        viewModel.completion = { [weak self] in
            guard let strongSelf = self else {return}
            strongSelf.test(strongSelf.controller)
            
        }
        view.viewModel = viewModel
        controller.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor).isActive = true
        
    }
    
    func test(_ controller: UIViewController){
        print("self = \(self.controller)")
    }
    
    deinit {
        print("TestCoordinator deinit")
    }
}
