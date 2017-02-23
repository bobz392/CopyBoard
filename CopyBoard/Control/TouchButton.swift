
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
//        self.addTarget(self, action: #selector(self.buttonAnimationStartAction), for: .touchDown)
//        self.addTarget(self, action: #selector(self.buttonAnimationEndAction), for: .touchUpOutside)
//        self.addTarget(self, action: #selector(self.buttonAnimationEndAction), for: .touchDragOutside)
//        self.addTarget(self, action: #selector(self.buttonAnimationEndAction), for: .touchUpInside)
//        self.addTarget(self, action: #selector(self.buttonAnimationEndAction), for: .touchCancel)
//        
        self.adjustsImageWhenHighlighted = false
        self.reversesTitleShadowWhenHighlighted = false
        self.tintColor = UIColor.white
    }
    
    func buttonAnimationStartAction() {
      
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        UIView.animate(withDuration: duration) { [unowned self] in
            if self.useTint {
                self.tintColor = self.selectedBgColor
            } else {
                self.backgroundColor = self.selectedBgColor
            }
        }
        self.isHighlighted = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.buttonAnimationEndAction()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        self.buttonAnimationEndAction()
    }
    
}
