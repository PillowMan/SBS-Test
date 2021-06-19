//
//  ApplePayCoordinator.swift
//  TestNotificationContent
//
//  Created by Dmitry Grigoryev on 19.06.2021.
//

import UIKit

class ApplePayCoordinator: BaseCoordinator {
    
    private var viewController: UIViewController
    private var applePayContent: ApplePayContent
    
    init(applePayContent: ApplePayContent, viewController: UIViewController){
        self.viewController = viewController
        self.applePayContent = applePayContent
    }
    
    override func start(){
        let viewModel = ApplePayContentViewModel(model: applePayContent)
        viewModel.errorCompletion = { error in
//            guard let self = self else {
//                let childs = self.childCoordinators
//                print("*** Self = \(self)")
//                return}
            self.showError(error, in: self.viewController)
            
        }
        
        let view = ApplePayContentView.loadFromNib()
        view.viewModel = viewModel
        viewController.removePreviousViewsAndAdd(view: view)
    }
    
    func showError(_ viewModel: ApplePayError, in controller: UIViewController){
       let errorCoordinator = ApplePayErrorCoordinator(applePayError: viewModel, viewController: controller)
        errorCoordinator.store(coordinator: errorCoordinator)
        errorCoordinator.start()
    }
    
}
