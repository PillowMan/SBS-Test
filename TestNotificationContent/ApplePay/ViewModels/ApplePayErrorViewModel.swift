//
//  ApplePayErrorViewModel.swift
//  TestNotificationContent
//
//  Created by Dmitry Grigoryev on 19.06.2021.
//

import Foundation

class ApplePayErrorViewModel{
    
    private var model: ApplePayError?
    
    var title: Box<String?> = Box(nil)
    var subTitle: Box<String?> = Box(nil)
    var confirmInCompletion: (()->Void)?
    
    
    init(model: ApplePayError){
        self.title.value = model.title
        self.subTitle.value = model.subTitle
    }
    
    
}
