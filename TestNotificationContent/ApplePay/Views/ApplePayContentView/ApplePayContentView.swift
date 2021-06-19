//
//  ApplePayContentState.swift
//  NotificationContent
//
//  Created by Dmitry Grigoryev on 12.06.2021.
//

import UIKit

class ApplePayContentView: UIView {
    
    var viewModel: ApplePayContentViewModel? { willSet (viewModel) {
        guard let viewModel = viewModel else { return }
        viewModel.title.bind{[weak self] value in self?.titleLabel.text = value}
    }}
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.backgroundColor = .green
        confirmButton.layer.cornerRadius = 15
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        
    }
}

extension ApplePayContentView {
    @objc func confirmButtonTapped(){
        viewModel?.payInCompletion?()
    }
}
