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
    
    init(sideMargin: CGFloat = 8) {
        self.sideMargin = sideMargin
        super.init(frame: CGRect.zero)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        self.addSubview(self.titleLabel)
        self.titleLabel.font = appFont(size: 17)
        self.titleLabel.textAlignment = .center
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(60)
            make.right.greaterThanOrEqualToSuperview().offset(-60)
        }
    }
    
    func addTableViewIndexCover(color: UIColor) {
        let view = UIView()
        view.backgroundColor = color
        self.addSubview(view)
        view.snp.makeConstraints { maker in
            maker.right.equalToSuperview()
            maker.width.equalTo(self.sideMargin)
            maker.bottom.equalToSuperview()
            maker.top.equalToSuperview()
        }
    }
    
    func addConstraint() {
        self.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview()
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
                maker.width.height.equalTo(self.barButtonSide)
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
