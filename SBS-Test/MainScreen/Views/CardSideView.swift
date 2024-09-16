//
//  CardSideView.swift
//  SBS-Test
//
//  Created by Dmitry Grigoryev on 21.08.2021.
//

import UIKit

class CardSideView: CustomView{
    
    var label:UILabel!
    
    var viewModel: CardSideViewModel? {
        willSet (viewModel){
            guard let viewModel = viewModel else {return}
            self.label.text = viewModel.text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.label = UILabel()
        self.label.textAlignment = .center
        
        self.addSubview(label)
        
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        
        self.layer.bounds.applying(CGAffineTransform(translationX: 20, y: 20))
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
