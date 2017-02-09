//
//  SettingView.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/9.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class SettingView {
    
    let realBarView = BarView()
    let closeButton = UIButton(type: .custom)
    let settingsTableView = UITableView(frame: .zero, style: .grouped)
    
    func config(view: UIView) {
        view.backgroundColor = AppColors.mainBackground
        self.configTableView(view: view)
    }
    
    func configBarView(bar: UINavigationBar) {
        bar.addSubview(self.realBarView)
        let barImage = AppColors.mainBackground.toImage()
        bar.shadowImage = barImage
        bar.setBackgroundImage(barImage, for: .default)
        self.realBarView.addConstraint()
        
        AppColors.mainBackground.bgColor(to: self.realBarView)
        self.realBarView.titleLabel.text = Localized("settings")
        
        self.realBarView.appendButtons(buttons: [closeButton], left: false)
        self.closeButton.setImage(Icons.done.iconImage(), for: .normal)
        self.closeButton.tintColor = AppColors.mainIcon
    }
    
    fileprivate func configTableView(view: UIView) {
        view.addSubview(self.settingsTableView)
        self.settingsTableView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
        self.settingsTableView.bgClear()
    }
    
}
