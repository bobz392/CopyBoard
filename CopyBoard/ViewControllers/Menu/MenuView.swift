//
//  MenuView.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/6.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class MenuView {    
    let menuTableView = UITableView()
    let headerView = UIView()
    let closeButton = TouchButton(type: .system)
    
    func configBar(bar: UIView) {
        self.headerView.backgroundColor = AppColors.cloudHeader
        
        let label = UILabel()
        label.text = Localized("infomation")
        label.textColor = AppColors.menuText
        label.font = appFont(size: 17)
        self.headerView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.left.equalToSuperview().offset(12)
        }
        
        bar.addSubview(self.headerView)
        self.headerView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
        
        let statusBarCoverView = UIView()
        bar.addSubview(statusBarCoverView)
        statusBarCoverView.backgroundColor = AppColors.cloudHeader
        statusBarCoverView.snp.makeConstraints { maker in
            maker.bottom.equalTo(self.headerView.snp.top)
            maker.height.equalTo(20)
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
        }
    }
    
    func configView(view: UIView) {
        view.addSubview(self.menuTableView)
        self.menuTableView.backgroundColor = AppColors.cloud
        self.menuTableView.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            
            maker.right.equalToSuperview()
            maker.left.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
        
        self.menuTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        self.menuTableView.separatorStyle = .none
        self.menuTableView.register(MenuDateTableCell.nib,
                                    forCellReuseIdentifier: MenuDateTableCell.reuseId)
        self.menuTableView.register(MenuDeviceTableCell.nib,
                                    forCellReuseIdentifier: MenuDeviceTableCell.reuseId)
        
        view.addSubview(self.closeButton)
        self.closeButton.useTint = false
        self.closeButton.snp.makeConstraints { maker in
            maker.bottom.equalToSuperview()
            maker.height.equalTo(44)
            maker.left.equalTo(self.menuTableView)
            maker.right.equalToSuperview()
        }
        
        self.closeButton.setTitleColor(AppColors.menuSecondaryText, for: .normal)
        self.closeButton.config(cornerRadius: 0)
        self.closeButton.bgColor = AppColors.cloudHeader
        self.closeButton.selectedBgColor = AppColors.mainBackground
        self.closeButton.setTitle(Localized("close"), for: .normal)
        
        let lineView = UIView()
        UIColor.lightGray.bgColor(to: lineView)
        view.addSubview(lineView)
        lineView.snp.makeConstraints { maker in
            maker.left.equalTo(self.menuTableView)
            maker.right.equalToSuperview()
            maker.top.equalTo(self.closeButton)
            maker.height.equalTo(0.5)
        }
    }
    
}
