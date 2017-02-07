
//
//  TouchButton.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/29.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

final class TouchButton: UIButton {
    
    func config() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = 8.0
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
        UIView.animate(withDuration: duration) {
            self.backgroundColor = AppColors.faveButton
        }
    }
    
    func buttonAnimationEndAction(_ btn: UIButton) {
        UIView.animate(withDuration: duration) {
            self.backgroundColor = UIColor.clear
        }
    }
    
}
