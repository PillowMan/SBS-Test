//
//  FlashCardView.swift
//  SBS-Test
//
//  Created by Dmitry Grigoryev on 21.08.2021.
//

import UIKit

class FlashCardView: CustomView, CAAnimationDelegate{
    
    typealias Action = ()->()
    
    var label:UILabel!
    var isBackside = false
    
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
    
    func degreeToRadian(degree: CGFloat) -> CGFloat{
        return (degree * .pi) / 180
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0/700
        self.layer.transform = perspective
        configTapGestureRecognizer()
        
        
       
    }
    
//    func configTapGesture(){
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(flipCard))
//        tapGestureRecognizer.numberOfTapsRequired = 1
//        self.addGestureRecognizer(tapGestureRecognizer)
//
//    }
    
    @objc func cardTapped(){
       
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configTapGestureRecognizer(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        self.tapGesture = tapGesture
        self.addGestureRecognizer(tapGesture)
    }
    
    
    //MARK: - Отвечает за переворот карты
    
    @objc func flipCard(){
        let scaleValue:CGFloat = 1.05
        let yRadian = self.degreeToRadian(degree: 180)
        let zRadian: CGFloat = self.degreeToRadian(degree: 20)
        
        
        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { timer in
            self.shadowLayer?.fillColor = self.isBackside ? UIColor.green.cgColor : UIColor.red.cgColor
        }
        
        var animations = [CABasicAnimation]()
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        scaleAnimation.fillMode = CAMediaTimingFillMode.forwards
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.autoreverses = true
        scaleAnimation.toValue = [scaleValue, scaleValue]
        scaleAnimation.duration = 0.3

        animations.append(scaleAnimation)

        let zRotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        zRotateAnimation.fillMode = CAMediaTimingFillMode.forwards
        zRotateAnimation.isRemovedOnCompletion = false
        zRotateAnimation.autoreverses = true
        zRotateAnimation.toValue = isBackside ? zRadian : -zRadian
        zRotateAnimation.duration = 0.15

        animations.append(zRotateAnimation)

        let xOffsetAnimation = CABasicAnimation(keyPath: "position")
        xOffsetAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        xOffsetAnimation.fillMode = CAMediaTimingFillMode.forwards
        xOffsetAnimation.isRemovedOnCompletion = false
        xOffsetAnimation.autoreverses = true
        xOffsetAnimation.toValue = [self.layer.position.x + (isBackside ? -40 : 40), self.layer.position.y + 15]
        xOffsetAnimation.duration = 0.15

        animations.append(xOffsetAnimation)

        let firstYRotateAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
        firstYRotateAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        firstYRotateAnimation.fillMode = CAMediaTimingFillMode.forwards
        firstYRotateAnimation.isRemovedOnCompletion = false
        firstYRotateAnimation.toValue = isBackside ? -yRadian : yRadian
        firstYRotateAnimation.duration = 0.30

        animations.append(firstYRotateAnimation)
        
        
       
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 0.3
//        animationGroup.fillMode = CAMediaTimingFillMode.forwards
//        animationGroup.isRemovedOnCompletion = false
        animationGroup.animations = animations
        self.layer.add(animationGroup, forKey: nil)
        self.isBackside = !self.isBackside
      
        
    }
  
    
    
}
