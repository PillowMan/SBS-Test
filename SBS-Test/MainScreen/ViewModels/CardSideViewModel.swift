//
//  CardSideViewModel.swift
//  SBS-Test
//
//  Created by Dmitry Grigoryev on 21.08.2021.
//

import Foundation

class CardSideViewModel {
    
    var text: String
    var number: Int
    
    init(number: Int, text: String) {
        self.number = number
        self.text = text
    }
}
