
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
            self.backgroundColor = bgColor
        }
    }
    
    var selectedBgColor = AppColors.faveButton
    var useTint = true
    
    func config(cornerRadius: CGFloat = 8.0) {
        self.layer.cornerRadius = cornerRadius
        self.addTarget(self, action: #selector(self.buttonAnimationStartAction(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(self.buttonAnimationEndAction(_:)), for: .touchUpOutside)
        self.addTarget(self, action: #selector(self.buttonAnimationEndAction(_:)), for: .touchDragOutside)
        self.addTarget(self, action: #selector(self.buttonAnimationEndAction(_:)), for: .touchUpInside)
        self.addTarget(self, action: #selector(self.buttonAnimationEndAction(_:)), for: .touchCancel)
        
        self.adjustsImageWhenHighlighted = false
        self.tintColor = UIColor.white
    }
    
    fileprivate var duration: TimeInterval = 0.35
    
    func buttonAnimationStartAction(_ btn: UIButton) {
        UIView.animate(withDuration: duration) { [unowned self] in
            if self.useTint {
                self.tintColor = self.selectedBgColor
            } else {
                self.backgroundColor = self.selectedBgColor
            }
            
        }
    }
    
    func buttonAnimationEndAction(_ btn: UIButton) {
        UIView.animate(withDuration: duration) { [unowned self] in
            if self.useTint {
                self.tintColor = self.bgColor
            } else {
                self.backgroundColor = self.bgColor
            }
        }
    }
    
}
