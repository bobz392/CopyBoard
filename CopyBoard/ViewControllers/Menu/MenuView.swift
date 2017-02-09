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
    let holderView = UIView()
    let closeButton = TouchButton(type: .custom)
    
    func configView(view: UIView) {

        view.addSubview(holderView)
        self.holderView.backgroundColor = AppColors.cloud
        self.holderView.snp.makeConstraints { maker in
            maker.right.equalToSuperview()
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.width.equalTo(280)
        }

        self.holderView.addSubview(self.menuTableView)
        self.menuTableView.bgClear()
        self.menuTableView.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
        
        self.menuTableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0)
        self.menuTableView.separatorStyle = .none
        self.menuTableView.allowsSelection = false
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
