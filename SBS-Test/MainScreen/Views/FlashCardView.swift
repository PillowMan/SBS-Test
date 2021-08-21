//
//  FlashCardView.swift
//  SBS-Test
//
//  Created by Dmitry Grigoryev on 21.08.2021.
//

import UIKit

class FlashCardView: CustomView {
    
    typealias Action = ()->()
    
    var label:UILabel!
    
    @objc var getstureTapAction: Action?
    
//    var frontView: CardSideView!
//    var backView: CardSideView!
    
    var tapGesture: UITapGestureRecognizer?
    
    var viewModel: FlashCardViewModel? {
        willSet (viewModel){
            guard let viewModel = viewModel else {return}
//            self.frontView.viewModel = viewModel.getFrontSideViewModel()
//            self.backView.viewModel = viewModel.getBackSideViewModel()
//            self.tapGesture?.isEnabled = viewModel.isVisible
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        let frontView = CardSideView()
//        self.frontView = frontView
//        self.addSubview(frontView)
        
//        frontView.translatesAutoresizingMaskIntoConstraints = false
//        frontView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true;
//        frontView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true;
//        frontView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true;
//        frontView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true;
//
//        let backView = CardSideView()
//        backView.isHidden = true
//        self.backView = backView
//        self.addSubview(backView)
//
//        backView.translatesAutoresizingMaskIntoConstraints = false
//        backView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true;
//        backView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true;
//        backView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true;
//        backView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true;
        
       
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configFlipTapGestureRecognizer(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        self.tapGesture = tapGesture
        self.addGestureRecognizer(tapGesture)
    }
    
    
    //MARK: - Отвечает за переворот карты
    
    @objc func flipCard(){
        
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromBottom]
        
        UIView.transition(with: self, duration: 0.5, options: transitionOptions, animations: {
//            self.frontView.isHidden = true
        })
        
        UIView.transition(with: self, duration: 0.5, options: transitionOptions, animations: {
//            self.backView.isHidden = false
        })
        
        
    }
    
//    func flip() {
//        let toView = viewModel.showingBack ? frontImageView : backImageView
//        let fromView = viewModel.showingBack ? backImageView : frontImageView
//               UIView.transitionFromView(fromView, toView: toView, duration: 1, options: .TransitionFlipFromRight, completion: nil)
//               toView.translatesAutoresizingMaskIntoConstraints = false
//               toView.spanSuperview()
//               showingBack = !showingBack
//           }
  
    
    
}
