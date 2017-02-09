//
//  PingTransition.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/9.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

final class PingTransition: NSObject, UIViewControllerAnimatedTransitioning, CAAnimationDelegate {

    internal let animationDuration: TimeInterval = 0.6
    var reverse = false

    fileprivate var transitionContext: UIViewControllerContextTransitioning? = nil
    fileprivate var maskLayer = CAShapeLayer()
    fileprivate var fromView: UIView? = nil

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
              let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }

        let vc = self.reverse ? toVC : fromVC
        guard let startVC = (vc as? UINavigationController)?.viewControllers.first as? PingStartViewDelegate else {
            fatalError("start vc not comfirm PingStartViewDelegate")
        }

        guard let fromView = fromVC.view,
              let toView = toVC.view
                else {
            fatalError("view is empty")
        }
        let startView = startVC.startView()

        self.transitionContext = transitionContext

        toView.frame = fromView.bounds
        toView.layoutIfNeeded()
        self.fromView = fromView

        self.animateTransition(transitionContext, fromView: fromView, toView: toView, startView: startView)
    }

    fileprivate func animateTransition(_ transitionContext: UIViewControllerContextTransitioning, fromView: UIView, toView: UIView, startView: UIView) {
        let containerView = transitionContext.containerView

        let v = self.reverse ? toView : fromView
        var bounds = v.convert(startView.frame, to: containerView)
        bounds.origin.y += DeviceManager.shared.statusbarHeight
        //var bounds = CGRect(x: 16, y: 32, width: 32, height: 32)
        if reverse {
            bounds.insetBy(dx: 15, dy: 15)
        }
        let maskStartPath = UIBezierPath(ovalIn: bounds)

        let finalPoint = self.calculateFinalPoint(startView: startView, toView: toView)
        let radius = sqrt(pow(finalPoint.x, 2) + pow(finalPoint.y, 2))
        let maskFinalPath = UIBezierPath(ovalIn: bounds.insetBy(dx: -radius, dy: -radius))
        //self.maskLayer.anchorPoint = startView.center

        if reverse {
            containerView.addSubview(toView)
            containerView.addSubview(fromView)

            self.maskLayer.path = maskStartPath.cgPath
            fromView.layer.mask = self.maskLayer

            let maskLayerAnimation = CABasicAnimation(keyPath: "path")
            maskLayerAnimation.duration = self.animationDuration
            maskLayerAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            maskLayerAnimation.delegate = self
            maskLayerAnimation.fromValue = maskFinalPath.cgPath
            maskLayerAnimation.toValue = maskStartPath.cgPath

            self.maskLayer.add(maskLayerAnimation, forKey: "path")
        } else {
            containerView.addSubview(fromView)
            containerView.addSubview(toView)

            self.maskLayer.path = maskFinalPath.cgPath
            toView.layer.mask = self.maskLayer

            let maskLayerAnimation = CABasicAnimation(keyPath: "path")
            maskLayerAnimation.duration = self.animationDuration
            maskLayerAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            maskLayerAnimation.delegate = self
            maskLayerAnimation.toValue = maskFinalPath.cgPath
            maskLayerAnimation.fromValue = maskStartPath.cgPath

            self.maskLayer.add(maskLayerAnimation, forKey: "path")
        }

    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard  let transitionContext = self.transitionContext else {
            fatalError("transitionContext = nil")
        }
        self.fromView?.removeFromSuperview()
        transitionContext.completeTransition(true)
        self.maskLayer.removeFromSuperlayer()
    }

    func calculateFinalPoint(startView: UIView, toView: UIView) -> CGPoint {
        if startView.frame.origin.x > toView.bounds.width * 0.5 {
            if startView.frame.origin.y < toView.bounds.height * 0.5 {
                return CGPoint(x: startView.center.x, y: startView.center.y - toView.bounds.maxY + 30.0)
            } else {
                return CGPoint(x: startView.center.x, y: startView.center.y)
            }
        } else {
            if startView.frame.origin.y < toView.bounds.height * 0.5 {
                return CGPoint(x: startView.center.x - toView.bounds.maxX, y: startView.center.y - toView.bounds.maxY + 30.0)
            } else {
                return CGPoint(x: startView.center.x - toView.bounds.maxX, y: startView.center.y)
            }
        }
    }

}

protocol PingStartViewDelegate {
    func startView() -> UIView
}
