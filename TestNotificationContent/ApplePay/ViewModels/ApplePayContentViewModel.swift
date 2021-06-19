//
//  ApplePayContentViewModel.swift
//  TestNotificationContent
//
//  Created by Dmitry Grigoryev on 19.06.2021.
//

import Foundation

class ApplePayContentViewModel{
    
    private var model: ApplePayContent?
    
    var title: Box<String?> = Box(nil)
    var subTitle: Box<String?> = Box(nil)
    var payInCompletion: (()->Void)?
    
    
    init(model: ApplePayContent){
        self.title.value = model.title
        self.subTitle.value = model.subTitle
    }
    
}
