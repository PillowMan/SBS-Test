//
//  FlashCardView.swift
//  SBS-Test
//
//  Created by Dmitry Grigoryev on 21.08.2021.
//

import UIKit
import SpriteKit

//TODO: - Исправить баг с перевернутой надписью Кошкой, когда отпускаешь свайп
//TODO: - Исправить краш, если нажать быстро еще раз до карты после свайпа
//TODO: - Сделать все жесты в одном методе https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/coordinating_multiple_gesture_recognizers/preferring_one_gesture_over_another https://www.google.com/search?q=UIPanGestureRecognizer+and+UITapGestureRecognizer&newwindow=1&client=safari&rls=en&biw=1252&bih=713&sxsrf=AOaemvJ1VTHxNe6ISeWrZdUoNzVAlXaI9A%3A1630869630513&ei=fhg1YejcHt6Rxc8P_cqQwAI&oq=UIPanGestureRecognizer+and+UITapGestureRecognizer&gs_lcp=Cgdnd3Mtd2l6EAMyBQgAEM0CMgUIABDNAjIFCAAQzQIyBQgAEM0CMgUIABDNAjoHCAAQRxCwAzoECCMQJzoKCAAQgAQQhwIQFDoFCAAQgAQ6BggAEAoQQzoFCAAQywE6BAgAEBM6CAgAEBYQHhATOgYIABAWEB46BAgAEB46BggAEAgQHjoGCAAQBxAeSgQIQRgAUM_KuQFYp466AWDuj7oBaANwAngAgAG5AYgBrA6SAQQwLjE1mAEAoAEBoAECyAEIwAEB&sclient=gws-wiz&ved=0ahUKEwjok4HoxujyAhXeSPEDHX0lBCgQ4dUDCA0&uact=5

class FlashCardView: UIView, CAAnimationDelegate{
    
    var frontView: CardSideView!
    var backView: CardSideView!
    
    var label:UILabel!
    
    var isAnimating = false
    var longPressed = false
    var isBackside = false {
        willSet {
            frontView.isHidden = newValue
            backView.isHidden = !newValue
        }
    }
    var tapGesture: UITapGestureRecognizer?
    var initialCenter = CGPoint()
    var maxOffset = CGPoint()
    var initialRotate = [0,0];
    var initialTransform: CATransform3D?
    var lastSwipeBeginPoint: CGPoint?
    var transformRotate: (x: CATransform3D, y: CATransform3D) = (CATransform3DIdentity, CATransform3DIdentity)
    
    //MARK: - Timer
    
    var endTime: CFTimeInterval?
    var displayLink: CADisplayLink?
    var startTouchTime: Date?
    
    
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
        self.maxOffset = CGPoint(x: 135, y: 75)
        configTapGestureRecognizer()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    
    
  /*
    @objc func translationPiece(_ sender: UIPanGestureRecognizer){
        guard let piece = sender.view else {return}
        
        let translation = sender.translation(in: piece.superview)
        switch sender.state {
        case .began:
            self.initialCenter = piece.center
            print("began in \(initialCenter)")
            break
        case .changed:
//            print("change \(translation)")
            let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
            self.center = newCenter
            
            //
            let offset = CGPoint(x: newCenter.x - initialCenter.x, y: newCenter.y - initialCenter.y)
            //                  x-axis
            if offset.x <= 200 && offset.x >= -200 {
                let degree = -0.20*offset.x
                let radian = self.degreeToRadian(degree: degree)
                var perspective = CATransform3DIdentity
                perspective.m34 = -1/700
                perspective = CATransform3DRotate(perspective, radian, 0, 1, 0)
                
                transformRotate.x = perspective
            }
            //                  y-axis
            if (offset.y <= 120 && offset.y >= -120) {
                let degree = 0.40*offset.y
                let radian = self.degreeToRadian(degree: degree)
                var perspective = CATransform3DIdentity
                perspective.m34 = -1/700
                perspective = CATransform3DRotate(perspective, radian, 1, 0, 0)
                
                transformRotate.y = perspective
            }
            self.layer.transform = CATransform3DConcat(transformRotate.x, transformRotate.y)
            
            break
        case .ended, .cancelled:
            print("Ended")
            
            UIView.animate(withDuration: 0.3) {
                piece.center = self.initialCenter
                piece.transform = .identity
            }
            
            //            UIView.animate(withDuration: 0.3){
            //                self.layer.transform = CATransform3DIdentity
            //                print("return identity")
            //            }
            
            //            var animations = [CABasicAnimation]()
            //
            //            let moveAnimation = CABasicAnimation(keyPath: "position")
            //            moveAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            //            moveAnimation.fillMode = CAMediaTimingFillMode.forwards
            //            moveAnimation.isRemovedOnCompletion = false
            //            moveAnimation.toValue = initialCenter
            //            moveAnimation.duration = 0.30
            //
            //            CATransaction.begin()
            //            CATransaction.setCompletionBlock{
            //                piece.center = self.initialCenter
            //            }
            //            piece.layer.add(moveAnimation, forKey: nil)
            //            CATransaction.commit()
            //            animations.append(moveAnimation)
            //
            //            let yRotation = CABasicAnimation(keyPath: "transform")
            //            yRotation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            //            yRotation.fillMode = CAMediaTimingFillMode.forwards
            //            yRotation.isRemovedOnCompletion = false
            //            yRotation.toValue = CATransform3DIdentity
            //            yRotation.duration = 0.30
            //
            //            animations.append(yRotation)
            //
            //            let animationGroup = CAAnimationGroup()
            //            animationGroup.duration = 0.30
            //            animationGroup.fillMode = CAMediaTimingFillMode.forwards
            //            animationGroup.isRemovedOnCompletion = false
            //            animationGroup.animations = animations
            //            animationGroup.delegate = self
            //            piece.layer.add(animationGroup, forKey: nil)
            break
        default:
            break
        }
    }
    */
    private func calculatePercentages(maxValue: CGPoint, currentValue: CGPoint) -> CGPoint{
        return CGPoint(x: maxValue.x/100*currentValue.x, y: maxValue.y/100*currentValue.y)
    }
    
    
    //MARK: - Отвечает за переворот карты
    
    func configTapGestureRecognizer(){
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(dragCard(_:)))
        dragGesture.maximumNumberOfTouches = 1
        self.addGestureRecognizer(dragGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        self.tapGesture = tapGesture
        self.addGestureRecognizer(tapGesture)
        self.initialTransform = self.layer.transform
    }
    
    @objc func longPressCard(_ gestureReconizer: UILongPressGestureRecognizer){
        if gestureReconizer.state != .began {return}
        print("Swipe")
    }
    
    //MARK: - Отвечает за перемещение карты
    //    https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/handling_uikit_gestures/handling_pan_gestures
    
    @objc func dragCard(_ sender: UIPanGestureRecognizer){
        guard let piece = sender.view else {return}
        let translation = sender.translation(in: piece.superview)
        self.lastSwipeBeginPoint = sender.location(in: piece)
        
        if sender.state == .began {
//            self.startTouchTime = Date()
            self.initialCenter = piece.center
            
            
        }
        if sender.state == .changed {
            
            guard let initialTransform = self.initialTransform else {return}
            let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
            self.center = newCenter
            let offset = CGPoint(x: newCenter.x - initialCenter.x, y: newCenter.y - initialCenter.y)
//            let location = sender.translation(in: self)
            let distance: CGFloat = 170
            // Calculate the x angle to the point "infront" of usn
            let xP = CGPoint(x: distance, y: offset.y)
            let xAngle = atan2(xP.y, xP.x)
            
            // Calculate the y angle to the point "infront" of us
            let yP = CGPoint(x: distance, y: offset.x)
            let yAngle = atan2(yP.y, yP.x)
            
            
            
//            guard let startTouchTime = self.startTouchTime else { return }
//            let interval = Date().timeIntervalSince(startTouchTime)
//            print(interval)
            var primaryTransform = CATransform3DIdentity
            primaryTransform.m34 = -1.0/700
            primaryTransform = CATransform3DRotate(initialTransform, isBackside ? yAngle : -yAngle, 0, 1, 0) // x axis
            primaryTransform = CATransform3DRotate(primaryTransform, xAngle, 1, 0, 0)
            piece.layer.transform = primaryTransform
        }
        
        if(sender.state == .ended || sender.state == .cancelled){
//            guard let beginPoint = lastSwipeBeginPoint else { return }
//            let endPoint = sender.location(in: piece)
                        returnCard()
           
            
            //            flipCard()
            //            var defaultTransform = CATransform3DIdentity
            //            CAtran3d
            //            defaultTransform.m34 = 1/700
            
            //            UIView.animate(withDuration: 0.4) {
            ////                guard let initialTransform = self.initialTransform else {return}
            ////                piece.layer.transform = initialTransform
            //                piece.center = self.initialCenter
            //            }
            
            
            //            piece.layer.add(transformAnimation, forKey: nil)
            
            
            //            UIView.animate(withDuration: 2.3) {
            //                guard let initialTransform = self.initialTransform else {return}
            //                piece.layer.transform = initialTransform
            //                piece.center = self.initialCenter
            //            }
            
        }
        
    }
    private func saveTransform(){
    var perspective = CATransform3DIdentity
    perspective.m34 = -1.0/700
        if isBackside {
            perspective = CATransform3DRotate(perspective, self.degreeToRadian(degree: 180), 0, 1, 0)
            self.initialTransform = perspective
        } else {
            self.initialTransform = perspective
        }
        self.layer.transform = perspective
    }
    
    
    @objc func changeView(){
        guard let endTime = endTime else {return}
        
        let currentTime = CACurrentMediaTime()
        if(currentTime >= endTime){
            displayLink?.isPaused = true
            displayLink?.invalidate()
            self.isBackside = !isBackside
        }
    }
    
    func returnCard(){
        guard let initialTransform = self.initialTransform else {return}
        let timeAnimation = 0.2
        
        UIView.animate(withDuration: timeAnimation) {
            self.layer.transform = initialTransform
            self.center = self.initialCenter
        }
    }
    
    
    @objc func flipCard(){
        guard !isAnimating else {return}
        let fullTimeAnimation = 0.6
        let halfTimeAnimation = fullTimeAnimation/2
        let scaleValue:CGFloat = 1.05
        let yRadian = self.degreeToRadian(degree: 180)
        
        //https://habr.com/ru/post/450172/
        
        let startTime = CACurrentMediaTime()
        self.endTime = halfTimeAnimation + startTime
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(changeView))
        self.displayLink?.add(to: .current, forMode: .common)
        
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        scaleAnimation.autoreverses = true
        scaleAnimation.toValue = [scaleValue, scaleValue]
        scaleAnimation.duration = halfTimeAnimation
        self.layer.add(scaleAnimation, forKey: nil)

        var animations = [CABasicAnimation]()
        
        let zRotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        zRotateAnimation.autoreverses = true
        zRotateAnimation.toValue = isBackside ? self.degreeToRadian(degree: 160) : self.degreeToRadian(degree: 20)
        zRotateAnimation.duration = halfTimeAnimation

        animations.append(zRotateAnimation)
        
        let xOffsetAnimation = CABasicAnimation(keyPath: "position")
        xOffsetAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        xOffsetAnimation.autoreverses = true
        xOffsetAnimation.toValue = [self.layer.position.x + (isBackside ? -40 : 40), self.layer.position.y + 15]
        xOffsetAnimation.duration = halfTimeAnimation

        animations.append(xOffsetAnimation)
        

        let firstYRotateAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
        firstYRotateAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        firstYRotateAnimation.toValue = -yRadian
        firstYRotateAnimation.duration = fullTimeAnimation
        firstYRotateAnimation.isAdditive = true

        animations.append(firstYRotateAnimation)
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = fullTimeAnimation
        animationGroup.animations = animations
        animationGroup.delegate = self
        self.layer.add(animationGroup, forKey: nil)
        
    }
     
    
//    @objc func flipCard(){
//        guard !isAnimating else {return}
//        let fullTimeAnimation = 1.0
//        let halfTimeAnimation = fullTimeAnimation/2
//        let scaleValue:CGFloat = 1.05
//        let yRadian = self.degreeToRadian(degree: 180)
//
//        let startTime = CACurrentMediaTime()
//        self.endTime = halfTimeAnimation + startTime
//
//        self.displayLink = CADisplayLink(target: self, selector: #selector(changeView))
//        self.displayLink?.add(to: .current, forMode: .common)
//
//        UIView.animate(withDuration: fullTimeAnimation) {
//            self.layer.transform = CATransform3DMakeRotation(self.degreeToRadian(degree: 180), 0, 1, 0)
//        }
//        UIView.animate(withDuration: halfTimeAnimation, delay: 0, options: [.autoreverse]) {
//            self.transform = CGAffineTransform(rotationAngle: self.degreeToRadian(degree: self.isBackside ? -20 : 20))
//        } completion: { finished in
//            self.transform = CGAffineTransform(rotationAngle: 0)
//        }
//
//    }
    
    func animationDidStart(_ anim: CAAnimation) {
        self.isAnimating = true
       
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.isAnimating = false
        self.saveTransform()
    }
    
    
}
