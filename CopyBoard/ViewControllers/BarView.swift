//
//  BarView.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/29.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class BarView: UIView {

    let sideMargin: CGFloat
    let barButtonSide: CGFloat = 32
    
    let titleLabel = UILabel()
    fileprivate var leftButtons = [UIButton]()
    fileprivate var rightButtons = [UIButton]()
    
    init(sideMargin: CGFloat = 12) {
        self.sideMargin = sideMargin
        super.init(frame: CGRect.zero)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        self.addSubview(self.titleLabel)
        self.titleLabel.font = appFont(size: 16, weight: UIFontWeightMedium)
        self.titleLabel.textAlignment = .center
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(60)
            make.right.greaterThanOrEqualToSuperview().offset(-60)
        }
    }
    
    func addConstraint() {
        self.snp.makeConstraints { maker in
            maker.top.equalToSuperview()//.offset(UIApplication.shared.statusBarFrame.height)
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.height.equalTo(44)
        }
    }
    
    func appendButtons(buttons: [UIButton], left: Bool) {
        var current = self.sideMargin
        if left {
            self.leftButtons.append(contentsOf: buttons)
        } else {
            self.rightButtons.append(contentsOf: buttons)
        }
        
        for btn in buttons {
            self.addSubview(btn)
            btn.snp.makeConstraints({ maker in
                maker.centerY.equalToSuperview()
                maker.height.equalTo(self.barButtonSide)
                maker.width.equalTo(self.barButtonSide)
                if left {
                    maker.left.equalToSuperview().offset(current)
                } else {
                    maker.right.equalToSuperview().offset(-current)
                }
            })
            
            current += self.sideMargin + self.barButtonSide
        }
    }
    
    func setTitle(title: String) {
        self.titleLabel.text = title
    }

}
