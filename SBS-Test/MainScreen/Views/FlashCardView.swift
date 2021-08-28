//
//  FlashCardView.swift
//  SBS-Test
//
//  Created by Dmitry Grigoryev on 21.08.2021.
//

import UIKit

class FlashCardView: UIView, CAAnimationDelegate{
    
    var frontView: CardSideView!
    var backView: CardSideView!
    
    var label:UILabel!
    
    var isAnimating = false
    var isBackside = false {
        willSet {
            frontView.isHidden = newValue
            backView.isHidden = !newValue
        }
    }
    
    var tapGesture: UITapGestureRecognizer?
    
    var viewModel: FlashCardViewModel? {
        willSet (viewModel){
            guard let viewModel = viewModel else {return}
            self.frontView.viewModel = viewModel.getFrontSideViewModel()
            self.backView.viewModel = viewModel.getBackSideViewModel()
            //            self.tapGesture?.isEnabled = viewModel.isVisible
        }
    }
    
    func degreeToRadian(degree: CGFloat) -> CGFloat{
        return (degree * .pi) / 180
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        frontView = CardSideView()
        frontView.isHidden = isBackside
        self.addSubview(frontView);
        
        frontView.translatesAutoresizingMaskIntoConstraints = false
        frontView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        frontView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        frontView.widthAnchor.constraint(equalToConstant: 270).isActive = true
        frontView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        backView = CardSideView()
        backView.isHidden = !isBackside
        self.addSubview(backView)
        
        backView.layer.transform = CATransform3DMakeRotation(self.degreeToRadian(degree: 180), 0, 1, 0)
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        backView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        backView.widthAnchor.constraint(equalToConstant: 270).isActive = true
        backView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0/700
        self.layer.transform = perspective
        configTapGestureRecognizer()
        
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
        guard !isAnimating else {return}
        
        let scaleValue:CGFloat = 1.05
        let yRadian = self.degreeToRadian(degree: 180)
        
        
        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { timer in
            self.isBackside = !self.isBackside
        }
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        scaleAnimation.autoreverses = true
        scaleAnimation.toValue = [scaleValue, scaleValue]
        scaleAnimation.duration = 0.15
        self.layer.add(scaleAnimation, forKey: nil)
        
        var animations = [CABasicAnimation]()
       
        let zRotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        zRotateAnimation.autoreverses = true
        zRotateAnimation.toValue = isBackside ? self.degreeToRadian(degree: -200) : self.degreeToRadian(degree: 20)
        zRotateAnimation.duration = 0.15
        
        animations.append(zRotateAnimation)
        
        let xOffsetAnimation = CABasicAnimation(keyPath: "position")
        xOffsetAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        xOffsetAnimation.autoreverses = true
        xOffsetAnimation.toValue = [self.layer.position.x + (isBackside ? 40 : -40), self.layer.position.y + 15]
        xOffsetAnimation.duration = 0.15
        
        animations.append(xOffsetAnimation)
        
        let firstYRotateAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
        firstYRotateAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        firstYRotateAnimation.toValue = -yRadian
        firstYRotateAnimation.duration = 0.30
        
        animations.append(firstYRotateAnimation)
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 0.3
        animationGroup.fillMode = CAMediaTimingFillMode.forwards
        animationGroup.isRemovedOnCompletion = false
        animationGroup.animations = animations
        animationGroup.delegate = self
        self.layer.add(animationGroup, forKey: nil)
        
        
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        self.isAnimating = true;
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.isAnimating = false;
    }
    
    
    
}
