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
    let settingsTableView = UITableView()
    
    func config(view: UIView) {
        view.backgroundColor = AppColors.mainBackground
        self.configBarView(view: view)
        self.configTableView(view: view)
    }
    
    fileprivate func configBarView(view: UIView) {
        view.addSubview(self.realBarView)
        self.realBarView.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(DeviceManager.shared.statusbarHeight)
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.height.equalTo(44)
        }
        
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
            maker.top.equalTo(self.realBarView.snp.bottom)
            maker.bottom.equalToSuperview()
        }
        self.settingsTableView.bgClear()
    }
    
}
