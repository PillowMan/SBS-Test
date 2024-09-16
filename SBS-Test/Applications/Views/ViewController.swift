//
//  ViewController.swift
//  SBS-Test
//
//  Created by Dmitry Grigoryev on 14.06.2021.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let flashCard = FlashCard(definition: "Cat", meaning: "Кошка", color: .Blue)
        let viewModel = FlashCardViewModel(number: 0, card: flashCard)
        let view = FlashCardView()
        view.viewModel = viewModel
        self.view.addSubview(view)
        
        
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        view.widthAnchor.constraint(equalToConstant: 270).isActive = true
        view.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        
        
    }
    
}

