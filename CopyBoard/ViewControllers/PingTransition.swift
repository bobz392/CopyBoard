//
//  PingTransition.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/9.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

final class PingTransition: UIViewControllerAnimatedTransitioning {
    
    internal let animationDuration: TimeInterval = 0.6
    var reverse = false
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
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
    
    fileprivate func animateTransition(_ transitionContext: UIViewControllerContextTransitioning, fromView: UIView, toView: UIView) {
        let containerView = transitionContext.containerView
        
    }
    
}
