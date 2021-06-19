//
//  ApplePayErrorView.swift
//  NotificationContent
//
//  Created by Dmitry Grigoryev on 13.06.2021.
//

import UIKit
class ApplePayErrorView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var viewModel: ApplePayContentViewModel?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}
