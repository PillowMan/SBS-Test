//
//  ApplePayViewModel.swift
//  SBS-Test
//
//  Created by Dmitry Grigoryev on 20.06.2021.
//

import Foundation

class ApplePayViewModel {
    var title: String?
    var completion: (()->Void)?
    init(_ model: ApplePayContent) {
        self.title = model.title
    }
    func confirm(){
        completion?()
    }
}
