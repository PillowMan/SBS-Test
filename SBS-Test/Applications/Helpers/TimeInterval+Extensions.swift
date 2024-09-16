//
//  TimeInterval+Extensions.swift
//  SBS-Test
//
//  Created by Dmitry Grigoryev on 07.10.2021.
//

import Foundation

extension TimeInterval {
    
    var seconds: Int {
        return Int(self.rounded())
    }
    
    var milliseconds: Int {
        return Int(self.rounded() * 1000)
    }
}
