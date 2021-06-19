//
//  ApplePayErrorCoordinator.swift
//  TestNotificationContent
//
//  Created by Dmitry Grigoryev on 20.06.2021.
//

import UIKit

class ApplePayErrorCoordinator: BaseCoordinator {
    
    private var viewController: UIViewController
    private var applePayError: ApplePayError
    
    init(applePayError: ApplePayError, viewController: UIViewController){
        self.viewController = viewController
        self.applePayError = applePayError
    }
    
    override func start() {
        let viewModel = ApplePayErrorViewModel(model: applePayError)
        let view = ApplePayErrorView.loadFromNib()
        view.viewModel = viewModel
        viewController.removePreviousViewsAndAdd(view: view)
    }
}
