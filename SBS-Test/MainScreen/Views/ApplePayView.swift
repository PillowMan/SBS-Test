//
//  ApplePayView.swift
//  SBS-Test
//
//  Created by Dmitry Grigoryev on 20.06.2021.
//

import UIKit

class ApplePayView: UIView {
    
    var title: UILabel!
    var button: UIButton!
    
    var viewModel: ApplePayViewModel? { willSet(viewModel){
        guard let viewModel = viewModel else {
            return
        }
        self.title.text = viewModel.title
    }}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeLayout(){
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = 30
        self.addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        stack.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: stack.heightAnchor).isActive = true
        
        title = UILabel()
        title.textColor = .black
        stack.addArrangedSubview(title)
        
        button = UIButton()
        button.setTitle("Confirm", for: .normal)
        button.backgroundColor = .green
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        stack.addArrangedSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
}

extension ApplePayView {
    @objc func confirmButtonTapped(){
        viewModel?.confirm()
    }
}

