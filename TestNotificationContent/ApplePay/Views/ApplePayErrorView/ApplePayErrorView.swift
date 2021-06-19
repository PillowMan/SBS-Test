//
//  ApplePayErrorView.swift
//  NotificationContent
//
//  Created by Dmitry Grigoryev on 13.06.2021.
//

import UIKit
class ApplePayErrorView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    var viewModel: ApplePayErrorViewModel? { willSet (viewModel) {
        guard let viewModel = viewModel else { return }
        viewModel.title.bind{[weak self] value in self?.titleLabel.text = value}
    }}
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.backgroundColor = .red
        confirmButton.layer.cornerRadius = 15
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }
}

extension ApplePayErrorView {
    @objc func confirmButtonTapped(){
        viewModel?.confirmInCompletion?()
    }
}
