//
//  ApplePayCoordinator.swift
//  TestNotificationContent
//
//  Created by Dmitry Grigoryev on 19.06.2021.
//

import UIKit

class ApplePayCoordinator {
    
    private var viewController: UIViewController
    private var applePayContent: ApplePayContent
    
    init(applePayContent: ApplePayContent, viewController: UIViewController){
        self.viewController = viewController
        self.applePayContent = applePayContent
    }
    
    func start(){
        let viewModel = ApplePayContentViewModel(model: applePayContent)
        viewModel.payInCompletion = {print("Confirm view")}
        let view = ApplePayContentView.loadFromNib()
        view.viewModel = viewModel
        viewController.removePreviousViewsAndAdd(view: view)
    }
    
}
