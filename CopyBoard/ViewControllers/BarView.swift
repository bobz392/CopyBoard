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
    let barButtonSide: CGFloat = 40
    
    let titleLabel = UILabel()
    fileprivate var leftButtons = [UIButton]()
    fileprivate var rightButtons = [UIButton]()
    
    init(sideMargin: CGFloat = 0) {
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
        if left {
            leftButtons.append(contentsOf: buttons)
        } else {
            rightButtons.append(contentsOf: buttons)
        }
        var lastButton: UIButton? = nil
        for btn in buttons {
            addSubview(btn)
            btn.snp.makeConstraints({ maker in
                maker.centerY.equalToSuperview()
                    .offset(2)
                maker.width.height
                    .equalTo(barButtonSide)
                if let lb = lastButton {
                    if left {
                        maker.left
                            .equalTo(lb.snp.right)
                            .offset(sideMargin)
                    } else {
                        maker.right
                            .equalTo(lb.snp.left)
                            .offset(-sideMargin)
                    }
                } else {
                    if left {
                        maker.left
                        .equalToSuperview()
                        .offset(sideMargin)
                    } else {
                        maker.right
                            .equalToSuperview()
                            .offset(-sideMargin)
                    }
                }
            })
            lastButton = btn
            btn.imageView?.contentMode = .scaleAspectFit
            btn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5,
                                               bottom: 5, right: 5)
        }
    }
    
    func buttonsSearchLayoutChange(startSearch: Bool) {
        titleLabel
            .snp.updateConstraints({ (maker) in
                maker.centerY
                    .equalToSuperview()
                    .offset(startSearch ? 11 : 0)
            })
        
        if let leftFirstBtn = leftButtons.first {
            let leftSide: CGFloat
            if startSearch {
                let count = CGFloat(leftButtons.count)
                leftSide =
                    -count * (barButtonSide + sideMargin)
            } else {
                leftSide = sideMargin
            }

            leftFirstBtn.snp.updateConstraints
                { (maker) in
                    maker.left.equalToSuperview()
                        .offset(leftSide)
            }
        }
        
        if let rightFirstBtn = rightButtons.first {
            let rightSide: CGFloat
            if startSearch {
                let count = CGFloat(rightButtons.count)
                rightSide =
                    count * (barButtonSide + sideMargin)
            } else {
                rightSide = -sideMargin
            }
            rightFirstBtn.snp.updateConstraints
                { (maker) in
                    maker.right.equalToSuperview()
                        .offset(rightSide)
            }
        }
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
}
