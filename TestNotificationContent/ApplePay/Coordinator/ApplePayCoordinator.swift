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
        viewModel.errorCompletion = { [weak self] error in
            guard let strongSelf = self else {return}
            strongSelf.showError(error, in: strongSelf.viewController)
            
        }
        
        let view = ApplePayContentView.loadFromNib()
        view.viewModel = viewModel
        viewController.removePreviousViewsAndAdd(view: view)
    }
    
    func showError(_ viewModel: ApplePayError, in controller: UIViewController){
       let errorCoordinator = ApplePayErrorCoordinator(applePayError: viewModel, viewController: controller)
//        errorCoordinator.store(coordinator: errorCoordinator)
        errorCoordinator.start()
    }
    
    deinit {
        print("*** ApplePayCoordinator deinit")
    }
    
}
