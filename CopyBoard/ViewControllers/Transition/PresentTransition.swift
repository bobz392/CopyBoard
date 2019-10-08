//
//  TransitioningAnimation.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/30.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

final class PresentTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    internal let animationDuration: TimeInterval = 0.25
    var reverse: Bool = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using vcCtx: UIViewControllerContextTransitioning) {
        let fromVc = vcCtx.viewController(forKey:.from)
        let toVc = vcCtx.viewController(forKey:.to)
        print("fromVc is", type(of: fromVc!), "toVc is", type(of: toVc!))
        
        let containerView = vcCtx.containerView
        containerView.backgroundColor = UIColor.black
        
        let fromView = vcCtx.view(forKey:.from)
        let toView = vcCtx.view(forKey:.to)
        
        let blackMaskView = UIView(frame: containerView.bounds)
        blackMaskView.backgroundColor = UIColor.black
        
        if !reverse {
            if let toView = toView { // presenting
                print("presentation animation")
                containerView.addSubview(toView)
                let finalFrame = toView.frame
                var startFrame = finalFrame
                startFrame.origin.y += startFrame.height
                toView.frame = startFrame
                
                var transform: CGAffineTransform?
                let fromImageView = UIImageView()
                
                if let fromVCView = fromVc?.view {
                    fromImageView.image = fromVCView.asImage()
                    fromImageView.frame = containerView.bounds
                    containerView.insertSubview(fromImageView, at: 0)
                    blackMaskView.alpha = 0
                    containerView.insertSubview(blackMaskView, at: 1)
                    transform = fromImageView.transform.scaledBy(x: 0.9, y: 0.9)
                }
                
                UIView.animate(withDuration: animationDuration,
                               delay: 0,
                               options: .curveEaseOut,
                               animations: {
                                if let _ = fromVc?.view,
                                    let transform = transform {
                                    blackMaskView.alpha = 0.8
                                    fromImageView.transform = transform
                                }
                                toView.frame = finalFrame
                }) { (finish) in
                    if let _ = fromVc?.view {
                        blackMaskView.removeFromSuperview()
                        fromImageView.removeFromSuperview()
                    }
                    vcCtx.completeTransition(!vcCtx.transitionWasCancelled)
                }
            }
        } else {
            if let fromView = fromView { // dismissing
                print("dismissal animation")
                
                var finalFrame = fromView.frame
                finalFrame.origin.y += fromView.frame.height
                let identity = fromView.transform
                
                let toImageView = UIImageView()
                toImageView.frame = containerView.bounds
                
                if let toVcView = toVc?.view {
                    toImageView.image = toVcView.asImage()
                    blackMaskView.alpha = 0.3
                    containerView.insertSubview(toImageView, at: 0)
                    let transform = identity.scaledBy(x: 0.9, y: 0.9)
                    toImageView.transform = transform
                    containerView.insertSubview(blackMaskView, at: 1)
                }
                
                UIView.animate(withDuration: animationDuration, delay: 0,
                               options: .curveEaseIn,
                               animations: {
                                toImageView.transform = identity
                                blackMaskView.alpha = 0
                                fromView.frame = finalFrame
                }, completion: { (finish) in
                    blackMaskView.removeFromSuperview()
                    toImageView.removeFromSuperview()
                    vcCtx.completeTransition(!vcCtx.transitionWasCancelled)
                })
            }
        }
        
    }
    
//    fileprivate func animateTransition(_ transitionContext: UIViewControllerContextTransitioning, fromView: UIView, toView: UIView) {
//
//        let containerView = transitionContext.containerView
//
//        let blackMaskView = UIView(frame: fromView.bounds)
//        blackMaskView.backgroundColor = UIColor.black
//
//        let animationOptions: UIView.AnimationOptions = [.curveEaseInOut, .layoutSubviews]
//
//        if self.reverse {
//            containerView.addSubview(toView)
////            containerView.addSubview(fromView)
//            let startFrame = fromView.frame
//            var finalFrame = fromView.frame
//            finalFrame.origin.y += startFrame.height
//            blackMaskView.alpha = 0.8
//            toView.addSubview(blackMaskView)
//
//            let identity = fromView.transform
//            let transform = identity.scaledBy(x: 0.9, y: 0.9)
//            toView.transform = transform
//
//            UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: {
//                toView.transform = identity
//                blackMaskView.alpha = 0
////                fromView.frame = finalFrame
//            }, completion: { (finish) in
//                blackMaskView.removeFromSuperview()
//                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//            })
//        } else {
////            containerView.addSubview(fromView)
//            containerView.addSubview(toView)
//            let finalFrame = toView.frame
//            var startFrame = finalFrame
//            startFrame.origin.y += startFrame.height
//            toView.frame = startFrame
//
//            blackMaskView.alpha = 0
////            fromView.addSubview(blackMaskView)
//
//            let identity = fromView.transform
//            let transform = identity.scaledBy(x: 0.9, y: 0.9)
//
//            UIView.animate(withDuration: animationDuration, delay: 0,
//                           options: animationOptions, animations: {
////                fromView.transform = transform
//                blackMaskView.alpha = 0.8
//                toView.frame = finalFrame
//            }) { (finish) in
//                blackMaskView.removeFromSuperview()
//                fromView.transform = identity
//                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//            }
//        }
//    }
}

extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
