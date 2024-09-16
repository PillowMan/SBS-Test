//
//  FlashCardViewModel.swift
//  SBS-Test
//
//  Created by Dmitry Grigoryev on 21.08.2021.
//

import Foundation

class FlashCardViewModel {
    
    var card: FlashCard
    var number: Int
    var definition: String? {return card.definition}
    var meaning: String? {return card.meaning}
    var color: Color {return card.color}
    var frontSideDisplayed: Bool
//    var isTapGestureEnabled = false
    
    init(number: Int, card: FlashCard) {
        self.number = number
        self.card = card
        self.frontSideDisplayed = true
    }
    
    public func getFrontSideViewModel() -> CardSideViewModel? {
        guard let definition = definition else {
            return nil
        }
        return CardSideViewModel(number: number, text: definition)
    }
    
    public func getBackSideViewModel() -> CardSideViewModel? {
        guard let meaning = meaning else {
            return nil
        }
        return CardSideViewModel(number: number, text: meaning)
    }
    
}
