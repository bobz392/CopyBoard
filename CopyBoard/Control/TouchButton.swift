
//
//  TouchButton.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/29.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

final class TouchButton: UIButton {
    
    var bgColor: UIColor = UIColor.white {
        didSet {
            if self.useTint {
                self.tintColor = self.bgColor
            } else {
                self.backgroundColor = self.bgColor
            }
        }
    }
    
    var selectedBgColor = AppColors.faveButton
    var useTint = true
    fileprivate var duration: TimeInterval = 0.35
    
    func config(cornerRadius: CGFloat = 8.0) {
        self.layer.cornerRadius = cornerRadius
        self.adjustsImageWhenHighlighted = false
        self.tintColor = UIColor.white
    }
    
    func buttonAnimationStartAction() {
        UIView.animate(withDuration: duration) { [unowned self] in
            if self.useTint {
                self.tintColor = self.selectedBgColor
            } else {
                self.backgroundColor = self.selectedBgColor
            }
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        self.buttonAnimationStartAction()
        return super.beginTracking(touch, with: event)
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        self.buttonAnimationEndAction()
        super.endTracking(touch, with: event)
    }
    
    override func cancelTracking(with event: UIEvent?) {
        self.buttonAnimationEndAction()
        super.cancelTracking(with: event)
    }
    
    func buttonAnimationEndAction() {
        UIView.animate(withDuration: duration) { [unowned self] in
            if self.useTint {
                self.tintColor = self.bgColor
            } else {
                self.backgroundColor = self.bgColor
            }
        }
    }
    
}
