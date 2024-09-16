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

class FlashCardView: UIView, CAAnimationDelegate, UIGestureRecognizerDelegate{
    
    var frontView: CardSideView!
    var backView: CardSideView!
    var defaultWidth = 270.0
    var defaultHeight = 150.0
    
    var label:UILabel!
    
    var isAnimating = false
    var isSwipeMode = true
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
    
    var holdDragTime = 0.1
//    var isHolded = true
    
    
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
        frontView.widthAnchor.constraint(equalToConstant: self.defaultWidth).isActive = true
        frontView.heightAnchor.constraint(equalToConstant: self.defaultHeight).isActive = true
        
        backView = CardSideView()
        backView.isHidden = !isBackside
        self.addSubview(backView)
        
        backView.layer.transform = CATransform3DMakeRotation(self.degreeToRadian(degree: 180), 0, 1, 0)
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        backView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        backView.widthAnchor.constraint(equalToConstant: self.defaultWidth).isActive = true
        backView.heightAnchor.constraint(equalToConstant: self.defaultHeight).isActive = true
        
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
        
//        let swipGesture = UIPanGestureRecognizer(target: self, action: #selector(swipe(_:)))
//        swipGesture.maximumNumberOfTouches = 1
//        self.addGestureRecognizer(swipGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        self.tapGesture = tapGesture
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func longPressCard(_ gestureReconizer: UILongPressGestureRecognizer){
        if gestureReconizer.state != .began {return}
        print("Swipe")
    }
    
    var task: DispatchWorkItem?
    
    //MARK: - Отвечает за перемещение карты
    //    https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/handling_uikit_gestures/handling_pan_gestures
    
    @objc func dragCard(_ sender: UIPanGestureRecognizer){
        guard let piece = sender.view else {return}
        let translation = sender.translation(in: piece.superview)
        
        
        if sender.state == .began {
            piece.layer.transform.m34 = -1.0/700
            self.initialCenter = piece.center
            self.initialTransform = self.layer.transform
//            let task = DispatchWorkItem {
//                self.isHolded = false
//                sender.setTranslation(CGPoint(x: 0,y: 0), in: piece.superview)
//            }
//            self.task = task
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: task)
            
        }
        if sender.state == .changed {
                guard let initialTransform = self.initialTransform else {return}
                let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
                self.center = newCenter
                let offset = CGPoint(x: newCenter.x - initialCenter.x, y: newCenter.y - initialCenter.y)
                
                piece.layer.transform = rotateTo(offset)
           
        }
        
        if(sender.state == .ended || sender.state == .cancelled){
            print(piece.frame.size)
            guard let initialTransform = initialTransform else {
                return
            }

//            guard let beginPoint = lastSwipeBeginPoint else { return }
//            let endPoint = sender.location(in: piece)
            let xOffset = abs(translation.x)
            let yOffset = abs(translation.y)
            
            let xDirection:CGFloat = translation.x < 0 ? -1 : 1
            let yDirection:CGFloat = translation.y < 0 ? -1 : 1
            
            if xOffset > self.defaultWidth || yOffset > self.defaultHeight {
               
                self.returnCard()
           
           } else if (xOffset >= self.defaultWidth/3 && xOffset <= self.defaultWidth)
                || (yOffset >= defaultHeight/3 && yOffset <= self.defaultHeight) {
                let angle = atan2(translation.y, translation.x)
                var point = CGPoint(x: self.defaultWidth * xDirection, y: self.defaultHeight * yDirection)
                if xOffset / defaultWidth > yOffset / defaultHeight {
                    point.y = point.x * (sin(angle) / cos(angle))
                } else {
                    point.x = point.y * (cos(angle) / sin(angle))
                }
               if isBackside {
                   let startTime = CACurrentMediaTime()
                   self.endTime = 0.35 + startTime
               
                   self.displayLink = CADisplayLink(target: self, selector: #selector(changeView))
                   self.displayLink?.add(to: .current, forMode: .common)
                   
                   self.rotateTo(CGPoint(x: 0, y: 0), withDuration: 0.2) {
                       self.returnCard()
                   }
                   
               } else {
                   self.rotateTo(point, withDuration: 0.2) {
                       self.returnCard()
                   }
               }
               UIView.animate(withDuration: 0.2) {
                   piece.center = CGPoint(x: piece.center.x + point.x, y: piece.center.y + point.y)
               }
               
            
                
            } else {
                print("return card")
                let transform = self.layer.transform
                self.layer.transform = self.initialTransform!
                
                let transformAnimation = CABasicAnimation(keyPath: "transform")
                 transformAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
                transformAnimation.fromValue = transform
                transformAnimation.duration = 0.3
                self.layer.add(transformAnimation, forKey: nil)
                UIView.animate(withDuration: 0.3) {
                    self.center = self.initialCenter
                }
            }
            
//            self.task?.cancel()
            
//            if self.isHolded {
//                if self.isBackside {
//                    let animationTime = 0.6
//                    let rotateTime = animationTime / 2 / 2
//
//                    let startTime = CACurrentMediaTime()
//                    self.endTime = rotateTime + startTime
//
//                    self.displayLink = CADisplayLink(target: self, selector: #selector(changeView))
//                    self.displayLink?.add(to: .current, forMode: .common)
//
//                    UIView.animate(withDuration: animationTime/2) {
//                        let multiplier = abs(translation.x) > abs(translation.y) ? abs(piece.bounds.width/translation.x) : abs(piece.bounds.height/translation.y)
//                        guard multiplier > 0 else {return}
//                        piece.transform = CGAffineTransform(translationX: translation.x * multiplier, y: translation.y * multiplier)
//                    } completion: { finished in
//                        UIView.animate(withDuration: animationTime/2) {
//                            piece.transform = CGAffineTransform(translationX: 0, y: 0)
//                        }
//                    }
//
//                } else {
//                    UIView.animate(withDuration: 0.3) {
//                        let multiplier = abs(translation.x) > abs(translation.y) ? abs(piece.bounds.width/translation.x) : abs(piece.bounds.height/translation.y)
//                        guard multiplier > 0 else {return}
//                        piece.transform = CGAffineTransform(translationX: translation.x * multiplier, y: translation.y * multiplier)
//                    } completion: { finished in
//                        UIView.animate(withDuration: 0.3) {
//                            piece.transform = CGAffineTransform(translationX: 0, y: 0)
//                        }
//                    }
//                }
//
//            } else {
//                    returnCard()
//            }
           
//            self.isHolded = true
            
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
    
    //MARK: - Rotate transform
    private func rotateTo(_ offset: CGPoint) -> CATransform3D{
        guard let initialTransform = self.initialTransform else {return .defaultTransform}
        print("rotate")
        let distance: CGFloat = 170
        
        let xP = CGPoint(x: distance, y: offset.y)
        let xAngle = atan2(xP.y, xP.x)
        
        
        // Calculate the y angle to the point "infront" of us
        let yP = CGPoint(x: distance, y: offset.x)
        let yAngle = atan2(yP.y, yP.x)
        
        
        
        var primaryTransform = CATransform3DIdentity
        primaryTransform.m34 = -1.0/700
        primaryTransform = CATransform3DRotate(initialTransform, -yAngle, 0, 1, 0)
        primaryTransform = CATransform3DRotate(primaryTransform, isBackside ? -xAngle : xAngle, 1, 0, 0) // y axis
        return primaryTransform
    }
    
    //MARK: - Move with animation
    @objc func rotateTo(_ offset: CGPoint, withDuration: CGFloat, completion: (() -> Void)? = nil){
        print("animation rotate")
        // transform
        let primaryTransform = self.layer.transform
        let transform = self.rotateTo(offset)
        self.layer.transform = transform
        
        // completion
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        
        let transformAnimation = CABasicAnimation(keyPath: "transform")
        transformAnimation.fromValue = primaryTransform
        transformAnimation.duration = withDuration
        self.layer.add(transformAnimation, forKey: nil)
        CATransaction.commit()

    }
    
        
    @objc func swipe(_ sender: UIPanGestureRecognizer) {
//        guard self.isSwipeMode else {return}
        print("swipe")
        guard let piece = sender.view else {return}
        let translation = sender.translation(in: piece.superview)
        
        let halfWidth = piece.bounds.width / 2
        let halfHeight = piece.bounds.height / 2
        
        
        
        if sender.state == .began {
            piece.layer.transform.m34 = -1.0/700
            self.initialCenter = piece.center
            self.initialTransform = self.layer.transform
            let task = DispatchWorkItem {
                self.isSwipeMode = false
                sender.setTranslation(CGPoint(x: 0,y: 0), in: piece.superview)
            }
            self.task = task
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: task)
        }
        
        if(sender.state == .ended || sender.state == .cancelled){
            
         
            
            var xOffset = 0.0
            var yOffset = 0.0
            
            let xMul = translation.x / halfWidth
            let yMul = translation.y / halfWidth
            
            let xDirection:CGFloat = translation.x < 0 ? -1 : 1
            let yDirection:CGFloat = translation.y < 0 ? -1 : 1
            
            if abs(xMul) > 1 || abs(yMul) > 1 {
                xOffset = abs(xMul) > 1 ? (halfWidth * xDirection) : translation.x
                yOffset = abs(yMul) > 1 ? (halfHeight * yDirection) : translation.y
            } else {
                if abs(xMul) > abs(yMul) {
                    xOffset = halfWidth * xDirection
                    if translation.y != 0 {
                        yOffset = translation.y / ((halfWidth - abs(translation.x)) / halfWidth * translation.y) + translation.y
                    }
                } else {
                    if translation.x != 0 {
                        xOffset = ((halfHeight - abs(translation.y)) / halfHeight * translation.x) + translation.x
                    }
                    yOffset = halfHeight * yDirection
                }
                
//                    print("xOffset = \(xOffset) yOffset = \(yOffset) mul = \(multiplier)\nxTrans = \(translation.x) yTrans = \(translation.y)")
                
                
            }
            
            if isBackside {
                let startTime = CACurrentMediaTime()
                self.endTime = 0.15 + startTime
                
                self.displayLink = CADisplayLink(target: self, selector: #selector(changeView))
                self.displayLink?.add(to: .current, forMode: .common)
                
                
                self.layer.transform = .defaultTransform
                
                let transform = CABasicAnimation(keyPath: "transform")
                transform.duration = 0.3
                transform.fromValue = self.initialTransform
                self.layer.add(transform, forKey: nil)
            } else {
                let transform = CABasicAnimation(keyPath: "transform")
                transform.duration = 0.3
                transform.fromValue = self.initialTransform
                transform.toValue = rotateTo(CGPoint(x: xOffset, y: yOffset))
                transform.autoreverses = true
                self.layer.add(transform, forKey: nil)
            }
            
            
            
            let position = CABasicAnimation(keyPath: "position")
            position.autoreverses = true
            position.fromValue = self.initialCenter
            position.toValue = [ piece.center.x + xOffset * 2.1, piece.center.y + yOffset * 2.1]
            position.duration = 0.3
            self.layer.add(position, forKey: nil)
            }
//          self.task?.cancel()
       
       
            /*
            if self.isBackside {
                let animationTime = 0.6
                let rotateTime = animationTime / 2 / 2
                
                let startTime = CACurrentMediaTime()
                self.endTime = rotateTime + startTime
                
                self.displayLink = CADisplayLink(target: self, selector: #selector(changeView))
                self.displayLink?.add(to: .current, forMode: .common)
                
                UIView.animate(withDuration: animationTime/2) {
                    let multiplier = abs(translation.x) > abs(translation.y) ? abs(piece.bounds.width/translation.x) : abs(piece.bounds.height/translation.y)
                    guard multiplier > 0 else {
                        
                        return}
                    piece.transform = CGAffineTransform(translationX: translation.x * multiplier, y: translation.y * multiplier)
                } completion: { finished in
                            
                    UIView.animate(withDuration: animationTime/2) {
                        piece.transform = CGAffineTransform(translationX: 0, y: 0)
                    }
                }
           
            } else {
                
                var xOffset = 0.0
                var yOffset = 0.0
                
                let xMul = translation.x / halfWidth
                let yMul = translation.y / halfWidth
                
                let xDirection:CGFloat = translation.x < 0 ? -1 : 1
                let yDirection:CGFloat = translation.y < 0 ? -1 : 1
                
                if abs(xMul) > 1 || abs(yMul) > 1 {
                    xOffset = abs(xMul) > 1 ? (halfWidth * xDirection) : translation.x
                    yOffset = abs(yMul) > 1 ? (halfHeight * yDirection) : translation.y
                    print("Full swipe x = \(xOffset) y = \(yOffset)")
                } else {
                    
                //TODO: - если палец смещен по x-оси на 1, то нужно определить его смещение когда он дойдет до крайней точки Y
                    if abs(xMul) > abs(yMul) {
                        xOffset = halfWidth * xDirection
                        if translation.y != 0 {
                            yOffset = translation.y / ((halfWidth - abs(translation.x)) / halfWidth * translation.y) + translation.y
                        }
                    } else {
                        if translation.x != 0 {
                            xOffset = ((halfHeight - abs(translation.y)) / halfHeight * translation.x) + translation.x
                        }
                        yOffset = halfHeight * yDirection
                    }
                    
//                    print("xOffset = \(xOffset) yOffset = \(yOffset) mul = \(multiplier)\nxTrans = \(translation.x) yTrans = \(translation.y)")
                    
                    
                }
                
                let transform = CABasicAnimation(keyPath: "transform")
                transform.duration = 0.3
                transform.fromValue = self.initialTransform
                transform.toValue = rotate(CGPoint(x: xOffset, y: yOffset))
                transform.autoreverses = true
                self.layer.add(transform, forKey: nil)
                
                let position = CABasicAnimation(keyPath: "position")
                position.autoreverses = true
                position.fromValue = self.initialCenter
                position.toValue = [ piece.center.x + xOffset * 2.1, piece.center.y + yOffset * 2.1]
                position.duration = 0.3
                self.layer.add(position, forKey: nil)
            }
            
        }
        */
        
        
        
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
        print("return card")
        let transform = self.layer.transform
        self.layer.transform = .defaultTransform
        
        let transformAnimation = CABasicAnimation(keyPath: "transform")
         transformAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        transformAnimation.fromValue = transform
        transformAnimation.duration = 0.3
        self.layer.add(transformAnimation, forKey: nil)
        UIView.animate(withDuration: 0.3) {
            self.center = self.initialCenter
        }
    }
     
    
    /*
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
        zRotateAnimation.toValue = isBackside ? self.degreeToRadian(degree: -200) : self.degreeToRadian(degree: 20)
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
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.animations = animations
//        animationGroup.delegate = self
        self.layer.add(animationGroup, forKey: nil)
        
    }
    */
    
    // https://www.biteinteractive.com/taking-control-of-rotation-animations-in-ios/
    // https://oleb.net/blog/2012/11/prevent-caanimation-snap-back/
    // https://habr.com/ru/post/450172/
    // https://stackoverflow.com/questions/6059054/cabasicanimation-resets-to-initial-value-after-animation-completes
    
    @objc func flipCard(){
        print("flip card")
        guard !isAnimating else {return}
        let fullTimeAnimation = 0.6
        let halfTimeAnimation = fullTimeAnimation/2
        let scaleValue:CGFloat = 1.15
        let angle = isBackside ? CGFloat.pi : -CGFloat.pi
        
        let startTime = CACurrentMediaTime()
        self.endTime = halfTimeAnimation + startTime

        self.displayLink = CADisplayLink(target: self, selector: #selector(changeView))
        self.displayLink?.add(to: .current, forMode: .common)
        
        var animations = [CABasicAnimation]()
        
        // Scale
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        scaleAnimation.autoreverses = true
        scaleAnimation.toValue = [scaleValue, scaleValue]
        scaleAnimation.duration = halfTimeAnimation
        animations.append(scaleAnimation)
        
        // Position
        let xOffsetAnimation = CABasicAnimation(keyPath: "position")
        xOffsetAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        xOffsetAnimation.autoreverses = true
        xOffsetAnimation.toValue = [self.layer.position.x + (isBackside ? -40 : 40), self.layer.position.y + 15]
        xOffsetAnimation.duration = halfTimeAnimation
        animations.append(xOffsetAnimation)
        
        // Z-Rotate
        let zRotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        zRotateAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        zRotateAnimation.autoreverses = true
        zRotateAnimation.toValue = isBackside ? self.degreeToRadian(degree: 160) : self.degreeToRadian(degree: 20)
        zRotateAnimation.duration = halfTimeAnimation
        animations.append(zRotateAnimation)
        
        // Spin
        let spin = CABasicAnimation(keyPath: "transform.rotation.y")
        spin.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        spin.duration = fullTimeAnimation
        spin.toValue = angle
        animations.append(spin)
        
        // Update transform after animations
        
        var perspective = CATransform3DRotate(self.layer.transform, angle, 0, 1, 0)
        perspective.m34 = -1.0/700.0
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.layer.transform = perspective
            self.layer.removeAllAnimations()
        }
        
        // Group
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = fullTimeAnimation
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.animations = animations
        animationGroup.delegate = self
        self.layer.add(animationGroup, forKey: nil)
        CATransaction.commit()
    }
    
    //https://oleb.net/blog/2012/11/prevent-caanimation-snap-back/
    /*
    @objc func flipCard(){
        guard !isAnimating else {return}
        let initialTransform = self.layer.transform
        let fullTimeAnimation = 0.6
        let halfTimeAnimation = fullTimeAnimation/2
        
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0/700
        perspective = isBackside ? perspective : CATransform3DRotate(perspective, self.degreeToRadian(degree: 180), 0, 1, 0)
        
        print(self.layer.transform)
        
        self.layer.transform = perspective
        
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            print(self.layer.transform)
        }
        let yRotateAnimation = CABasicAnimation(keyPath: "transform")
        yRotateAnimation.fromValue = initialTransform
        yRotateAnimation.duration = 1
        self.layer.add(yRotateAnimation, forKey: "transform")
        CATransaction.commit()

        
//        let zRotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
//        zRotateAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
//        zRotateAnimation.autoreverses = true
//        zRotateAnimation.toValue = isBackside ? self.degreeToRadian(degree: -200) : self.degreeToRadian(degree: 20)
//        zRotateAnimation.duration = halfTimeAnimation
//        zRotateAnimation.isAdditive = true
//        self.layer.add(zRotateAnimation, forKey: "transform.rotation.z")
        
    }
    */
    func animationDidStart(_ anim: CAAnimation) {
        self.isAnimating = true
       
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.isAnimating = false
    }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
    
    
}
