//
//  TransitioningAnimation.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/30.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

final class PresentTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    internal let animationDuration: TimeInterval = 0.35
    var reverse = false
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }
        
        guard let fromView = fromVC.view,
            let toView = toVC.view
            else { fatalError("view is empty") }

        toView.frame = fromView.bounds
        toView.layoutIfNeeded()
        
        self.animateTransition(transitionContext, fromView: fromView, toView: toView)
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    fileprivate func animateTransition(_ transitionContext: UIViewControllerContextTransitioning, fromView: UIView, toView: UIView) {
        
        let containerView = transitionContext.containerView
        
        let blackMaskView = UIView(frame: fromView.bounds)
        blackMaskView.backgroundColor = UIColor.black

        let animationOptions: UIViewAnimationOptions = [.curveEaseInOut, .beginFromCurrentState, .layoutSubviews]
        
        if self.reverse {
            containerView.addSubview(toView)
            containerView.addSubview(fromView)
            let startFrame = fromView.frame
            var finalFrame = fromView.frame
            finalFrame.origin.y += startFrame.height
            blackMaskView.alpha = 0.8
            toView.addSubview(blackMaskView)
            
            let identity = fromView.transform
            let transform = identity.scaledBy(x: 0.9, y: 0.9)
            toView.transform = transform
            
            UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: { 
                toView.transform = identity
                blackMaskView.alpha = 0
                fromView.frame = finalFrame
            }, completion: { (finish) in
                blackMaskView.removeFromSuperview()
                //fromView.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        } else {
            containerView.addSubview(fromView)
            containerView.addSubview(toView)
            let finalFrame = toView.frame
            var startFrame = finalFrame
            startFrame.origin.y += startFrame.height
            toView.frame = startFrame
            
            blackMaskView.alpha = 0
            fromView.addSubview(blackMaskView)
            
            let identity = fromView.transform
            let transform = identity.scaledBy(x: 0.9, y: 0.9)
            
            UIView.animate(withDuration: animationDuration, delay: 0,
                           options: animationOptions, animations: {
                fromView.transform = transform
                blackMaskView.alpha = 0.8
                toView.frame = finalFrame
            }) { (finish) in
                blackMaskView.removeFromSuperview()
                fromView.transform = identity
                //fromView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }
}
