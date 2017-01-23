//
//  NoteTransition.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/22.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

enum NoteModalTransitonDirection: Int{
    case bottom
    case left
    case right
}


class NoteDetectScrollViewEndGestureRecognizer: UIPanGestureRecognizer {
    var scrollview :UIScrollView?
    fileprivate var  isFail :Bool?
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
    override func reset(){
        super.reset()
        self.isFail = false
    }
    
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesMoved(touches, with:event!)
        
        if self.scrollview == nil {
            return;
        }
        
        if self.state == UIGestureRecognizerState.failed{
            return
        }
        let velocity:CGPoint = self.velocity(in: self.view)
        let nowPoint:CGPoint = touches.first!.location(in: self.view)
        let prevPoint:CGPoint = touches.first!.previousLocation(in: self.view)
        
        if ((self.isFail) != nil) {
            if (self.isFail!) {
                self.state = UIGestureRecognizerState.failed
            }
            return;
        }
        
        let topVerticalOffset:CGFloat = -self.scrollview!.contentInset.top
        
        if ((fabs(velocity.x) < fabs(velocity.y)) && (nowPoint.y > prevPoint.y) && (self.scrollview!.contentOffset.y <= topVerticalOffset)) {
            self.isFail = false;
        } else if (self.scrollview!.contentOffset.y >= topVerticalOffset) {
            self.state = UIGestureRecognizerState.failed
            self.isFail = true
        } else {
            self.isFail = false
        }
    }
    
    
}
class NoteModalTransitionAnimator: UIPercentDrivenInteractiveTransition,UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {
    fileprivate var _dragable: Bool? = true
    
    
    var dragable: Bool{
        set {
            self._dragable = dragable
            
            if dragable {
                
                self.removeGestureRecognizerFromModalController()
                
                self.gesture = NoteDetectScrollViewEndGestureRecognizer(target: self, action: #selector(NoteModalTransitionAnimator.handlePan(_:)))
                
                self.gesture!.delegate = self
                
                self.modalController!.view.addGestureRecognizer(self.gesture!)
                
            } else {
                
                
                self.removeGestureRecognizerFromModalController()
            }
            
        }
        get {
            
            return self._dragable!
            
            
            
        }
    }
    
    func removeGestureRecognizerFromModalController(){
        
        
        //
        //        if (self.gesture != nil ) && self.modalController!.view.gestureRecognizers!.contains(self.gesture!) {
        //
        //            self.modalController!.view.removeGestureRecognizer(self.gesture!)
        //            self.gesture = nil;
        //        }
    }
    //    private(set) var gesture: NoteDetectScrollViewEndGestureRecognizer
    var  gestureRecognizerToFailPan: UIGestureRecognizer?
    var bounces: Bool
    var direction: NoteModalTransitonDirection = NoteModalTransitonDirection.bottom
    var behindViewScale,behindViewAlpha,transitionDuration :CGFloat
    
    weak fileprivate var modalController: UIViewController?
    fileprivate var gesture: NoteDetectScrollViewEndGestureRecognizer?
    fileprivate var transitionContext: UIViewControllerContextTransitioning?
    fileprivate var panLocationStart: CGFloat = 0.0
    fileprivate var isDismiss = true,isInteractive:Bool = false
    
    fileprivate var tempTransform: CATransform3D?
    
    
    init(modalViewController: UIViewController){
        
        
        self.bounces = true
        self.behindViewScale = 0.9
        self.behindViewAlpha = 1.0
        self.transitionDuration = 0.8
        
        self.gestureRecognizerToFailPan = UIGestureRecognizer()
        self.gesture = NoteDetectScrollViewEndGestureRecognizer()
        
        super.init()
        
        self.modalController = modalViewController
        //        self.dragable = true
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged(_:)), name:NSNotification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
        
    }
    deinit {
        // perform the deinitialization
        
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    func setContentScrollView(_ scrollView: UIScrollView?){
        // always enable drag if scrollview is set
        if !self.dragable {
            self.dragable = true
        }
        // and scrollview will work only for bottom mode
        self.direction = NoteModalTransitonDirection.bottom;
        self.gesture!.scrollview = scrollView;
    }
    
    func setDirection(_ direction :NoteModalTransitonDirection){
        self.direction = direction;
        // scrollview will work only for bottom mode
        if self.direction != NoteModalTransitonDirection.bottom {
            self.gesture!.scrollview = nil;
        }
    }
    
    func animationEnded(_ transitionCompleted: Bool){
        // Reset to our default state
        self.isInteractive = false
        self.transitionContext = nil
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) ->TimeInterval{
        return TimeInterval(self.transitionDuration)
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        if self.isInteractive {
            return;
        }
        // Grab the from and to view controllers from the context
        let  fromViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        
        
        let toViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let containerView: UIView = transitionContext.containerView
        
        if !self.isDismiss {
            
            var startRect: CGRect
            
            containerView.addSubview(toViewController.view)
            
            toViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            switch self.direction{
            case NoteModalTransitonDirection.bottom:
                startRect = CGRect(x: 0,
                                   y: containerView.frame.height,
                                   width: containerView.bounds.width,
                                   height: containerView.bounds.height)
                
            case NoteModalTransitonDirection.left:
                startRect = CGRect(x: -containerView.frame.width,
                                   y: 0,
                                   width: containerView.bounds.width,
                                   height: containerView.bounds.height);
                
            case NoteModalTransitonDirection.right:
                
                startRect = CGRect(x: containerView.frame.width,
                                   y: 0,
                                   width: containerView.bounds.width,
                                   height: containerView.bounds.height);
                
            }
            
            let transformedPoint: CGPoint = startRect.origin.applying(toViewController.view.transform);
            toViewController.view.frame = CGRect(x: transformedPoint.x, y: transformedPoint.y, width: startRect.size.width, height: startRect.size.height);
            
            if (toViewController.modalPresentationStyle == UIModalPresentationStyle.custom) {
                fromViewController.beginAppearanceTransition(false ,animated:true)
            }
            
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0,usingSpringWithDamping: 0.8,initialSpringVelocity: 0.1,options:UIViewAnimationOptions.curveEaseOut,animations:{
                fromViewController.view.transform = fromViewController.view.transform.scaledBy(x: self.behindViewScale, y: self.behindViewScale)
                fromViewController.view.alpha = self.behindViewAlpha
                
                toViewController.view.frame = CGRect(x: 0,y: 0,
                                                     width: toViewController.view.frame.width,
                                                     height: toViewController.view.frame.height)
                
            },completion: {(finished: Bool) in
                if toViewController.modalPresentationStyle == UIModalPresentationStyle.custom {
                    fromViewController.endAppearanceTransition()
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }else{
            
            if fromViewController.modalPresentationStyle == UIModalPresentationStyle.fullScreen {
                containerView.addSubview(toViewController.view)
            }
            
            containerView.bringSubview(toFront: fromViewController.view)
            
            if !self.isPriorToIOS8() {
                toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, self.behindViewScale, self.behindViewScale, 1);
            }
            
            toViewController.view.alpha = self.behindViewAlpha;
            
            var endRect: CGRect
            
            
            switch self.direction{
            case NoteModalTransitonDirection.bottom:
                endRect = CGRect(x: 0,
                                 y: fromViewController.view.bounds.height,
                                 width: fromViewController.view.frame.width,
                                 height: fromViewController.view.frame.height);
                
            case NoteModalTransitonDirection.left:
                endRect = CGRect(x: -fromViewController.view.bounds.width,
                                 y: 0,
                                 width: fromViewController.view.frame.width,
                                 height: fromViewController.view.frame.height);
                
            case NoteModalTransitonDirection.right:
                endRect = CGRect(x: fromViewController.view.bounds.width,
                                 y: 0,
                                 width: fromViewController.view.frame.width,
                                 height: fromViewController.view.frame.height)
                
            }
            
            let transformedPoint: CGPoint = endRect.origin.applying(fromViewController.view.transform);
            endRect = CGRect(x: transformedPoint.x, y: transformedPoint.y, width: endRect.size.width, height: endRect.size.height);
            
            if fromViewController.modalPresentationStyle == UIModalPresentationStyle.custom {
                toViewController.beginAppearanceTransition(true, animated:true)
            }
            
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                let scaleBack:CGFloat = (1 / self.behindViewScale)
                toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, scaleBack, scaleBack, 1)
                toViewController.view.alpha = 1.0
                fromViewController.view.frame = endRect
            }, completion: { (finished: Bool) -> Void in
                toViewController.view.layer.transform = CATransform3DIdentity;
                
                //FIXME: This is WRONG!
                
                if (fromViewController.modalPresentationStyle == UIModalPresentationStyle.custom) {
                    toViewController.endAppearanceTransition()
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
            
            
        }
    }
    
    //MARK: Utils
    
    func isPriorToIOS8()-> Bool{
        
        switch UIDevice.current.systemVersion.compare("8.0.0", options: NSString.CompareOptions.numeric) {
        case .orderedSame, .orderedDescending:
            return true
        case .orderedAscending:
            return false
        }
    }
    
    
    //MARK: - Gesture
    
    //    - (void)handlePan:(UIPanGestureRecognizer *)recognizer
    func handlePan(_ recognizer:UIPanGestureRecognizer){
        
        // Location reference
        var location: CGPoint = recognizer.location(in: self.modalController!.view.window)
        location = location.applying(recognizer.view!.transform.inverted())
        // Velocity reference
        var velocity:CGPoint = recognizer.velocity(in: self.modalController!.view.window)
        velocity = velocity.applying(recognizer.view!.transform.inverted())
        
        
        
        switch recognizer.state{
        case UIGestureRecognizerState.began:
            self.isInteractive = true
            if (self.direction == NoteModalTransitonDirection.bottom) {
                self.panLocationStart = location.y;
            } else {
                self.panLocationStart = location.x;
            }
            self.modalController?.dismiss(animated: true, completion: nil)
            
        case UIGestureRecognizerState.changed:
            var animationRatio:CGFloat = 0;
            
            if (self.direction == NoteModalTransitonDirection.bottom) {
            } else if (self.direction == NoteModalTransitonDirection.left) {
            } else if (self.direction == NoteModalTransitonDirection.right) {
            }
            
            switch self.direction{
            case NoteModalTransitonDirection.bottom:
                animationRatio = (location.y - self.panLocationStart) / (self.modalController!.view.bounds.height)
            case NoteModalTransitonDirection.left:
                animationRatio = (self.panLocationStart - location.x) / (self.modalController!.view.bounds.width)
            case NoteModalTransitonDirection.right:
                animationRatio = (location.x - self.panLocationStart) / (self.modalController!.view.bounds.width)
                
            }
            
            self.update(animationRatio)
            
        case UIGestureRecognizerState.ended:
            
            var velocityForSelectedDirection:CGFloat
            
            if (self.direction == NoteModalTransitonDirection.bottom) {
                velocityForSelectedDirection = velocity.y;
            } else {
                velocityForSelectedDirection = velocity.x;
            }
            
            if (velocityForSelectedDirection > 100
                && (self.direction == NoteModalTransitonDirection.right
                    || self.direction == NoteModalTransitonDirection.bottom)) {
                self.finish()
            } else if (velocityForSelectedDirection < -100 && self.direction == NoteModalTransitonDirection.left) {
                self.finish()
            } else {
                self.cancel()
            }
            self.isInteractive = false
            
            
        default: break
            
        }
    }
    
    //MARK:  -
    
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning){
        
        self.transitionContext = transitionContext;
        
        let fromViewController:UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController:UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        if (!self.isPriorToIOS8()) {
            toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, self.behindViewScale, self.behindViewScale, 1);
        }
        
        self.tempTransform = toViewController.view.layer.transform;
        
        toViewController.view.alpha = self.behindViewAlpha;
        
        if (fromViewController.modalPresentationStyle == UIModalPresentationStyle.fullScreen) {
            transitionContext.containerView.addSubview(toViewController.view)
        }
        transitionContext.containerView.bringSubview(toFront: fromViewController.view)
    }
    
    override func update(_ percentComplete: CGFloat){
        var percentComplete = percentComplete
        
        
        if !self.bounces && percentComplete < 0 {
            percentComplete = 0
        }
        
        let transitionContext:UIViewControllerContextTransitioning = self.transitionContext!
        
        let fromViewController:UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController:UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let transform:CATransform3D = CATransform3DMakeScale(
            1 + (((1 / self.behindViewScale) - 1) * percentComplete),
            1 + (((1 / self.behindViewScale) - 1) * percentComplete), 1);
        toViewController.view.layer.transform = CATransform3DConcat(self.tempTransform!, transform);
        
        toViewController.view.alpha = self.behindViewAlpha + ((1 - self.behindViewAlpha) * percentComplete);
        
        var updateRect:CGRect
        
        
        switch self.direction {
        case NoteModalTransitonDirection.bottom:
            updateRect = CGRect(x: 0,
                                y: (fromViewController.view.bounds.height * percentComplete),
                                width: fromViewController.view.frame.width,
                                height: fromViewController.view.frame.height);
        case NoteModalTransitonDirection.left:
            updateRect = CGRect(x: -(fromViewController.view.bounds.width * percentComplete),
                                y: 0,
                                width: fromViewController.view.frame.width,
                                height: fromViewController.view.frame.height);
        case NoteModalTransitonDirection.right:
            updateRect = CGRect(x: fromViewController.view.bounds.width * percentComplete,
                                y: 0,
                                width: fromViewController.view.frame.width,
                                height: fromViewController.view.frame.height);
        }
        
        
        // reset to zero if x and y has unexpected value to prevent crash
        
        
        
        if (updateRect.origin.x.isNaN || updateRect.origin.x.isInfinite) {
            updateRect.origin.x = 0;
        }
        if (updateRect.origin.y.isNaN || updateRect.origin.y.isInfinite) {
            updateRect.origin.y = 0;
        }
        
        let transformedPoint:CGPoint = updateRect.origin.applying(fromViewController.view.transform);
        updateRect = CGRect(x: transformedPoint.x, y: transformedPoint.y, width: updateRect.size.width, height: updateRect.size.height);
        
        fromViewController.view.frame = updateRect;
    }
    override func finish(){
        let transitionContext:UIViewControllerContextTransitioning = self.transitionContext!;
        
        let fromViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        var endRect:CGRect
        
        switch self.direction {
        case NoteModalTransitonDirection.bottom:
            endRect = CGRect(x: 0,
                             y: fromViewController.view.bounds.height,
                             width: fromViewController.view.frame.width,
                             height: fromViewController.view.frame.height);
        case NoteModalTransitonDirection.left:
            endRect = CGRect(x: -fromViewController.view.bounds.width,
                             y: 0,
                             width: fromViewController.view.frame.width,
                             height: fromViewController.view.frame.height);
        case NoteModalTransitonDirection.right:
            endRect = CGRect(x: fromViewController.view.bounds.width,
                             y: 0,
                             width: fromViewController.view.frame.width,
                             height: fromViewController.view.frame.height);
            
        }
        
        
        let transformedPoint:CGPoint = endRect.origin.applying(fromViewController.view.transform);
        endRect = CGRect(x: transformedPoint.x, y: transformedPoint.y, width: endRect.size.width, height: endRect.size.height);
        
        if fromViewController.modalPresentationStyle == UIModalPresentationStyle.custom {
            toViewController.beginAppearanceTransition(true, animated:true)
        }
        
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            let scaleBack:CGFloat = (1 / self.behindViewScale);
            toViewController.view.layer.transform = CATransform3DScale(self.tempTransform!, scaleBack, scaleBack, 1);
            toViewController.view.alpha = 1.0
            fromViewController.view.frame = endRect;
        }, completion: { (finished: Bool) -> Void in
            if (fromViewController.modalPresentationStyle == UIModalPresentationStyle.custom) {
                toViewController.endAppearanceTransition()
            }
            transitionContext.completeTransition(true)
        })
    }
    
    override func cancel(){
        guard let transitionContext = self.transitionContext else { return }
        transitionContext.cancelInteractiveTransition()
        
        let fromViewController:UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController:UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            toViewController.view.layer.transform = self.tempTransform!
            toViewController.view.alpha = self.behindViewAlpha
            
            fromViewController.view.frame = CGRect(x: 0,y: 0,
                                                   width: fromViewController.view.frame.width,
                                                   height: fromViewController.view.frame.height);
        }, completion: { (finished: Bool) -> Void in
            transitionContext.completeTransition(false)
            if fromViewController.modalPresentationStyle == UIModalPresentationStyle.fullScreen {
                toViewController.view.removeFromSuperview()
            }
        })
    }
    
    //MARK: - UIViewControllerTransitioningDelegate Methods
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        self.isDismiss = false
        return self
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        
        self.isDismiss = true
        return self
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
        
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // Return nil if we are not interactive
        if self.isInteractive && self.dragable {
            self.isDismiss = true
            return self
        }
        
        return nil;
        
    }
    
    
    
    //MARK: - Gesture Delegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.direction == NoteModalTransitonDirection.bottom {
            return true
        }
        return false
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (self.direction == NoteModalTransitonDirection.bottom) {
            return true
        }
        return false
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (self.gestureRecognizerToFailPan != nil)  && (self.gestureRecognizerToFailPan == otherGestureRecognizer) {
            return true
        }
        
        return false
    }
    
    
    
    func orientationChanged(_ notification: Notification) {
        let backViewController: UIViewController? = self.modalController!.presentingViewController
        backViewController!.view.transform = CGAffineTransform.identity
        backViewController!.view.frame = self.modalController!.view.bounds
        backViewController!.view.transform = backViewController!.view.transform.scaledBy(x: self.behindViewScale, y: self.behindViewScale)
    }
    
}
