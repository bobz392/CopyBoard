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
    let closeButton = UIButton(type: .custom)
    let headerView = UIView()
    
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
     
        self.menuTableView.register(MenuDateTableCell.nib,
                                    forCellReuseIdentifier: MenuDateTableCell.reuseId)
        self.menuTableView.tableFooterView = UIView()
    }
    
    func configHeaderView() {
        self.headerView.bgClear()
        let titleLabel = UILabel()
        titleLabel.font = appFont(size: 17)
        titleLabel.text = "信息"
        self.headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(8)
            maker.centerY.equalToSuperview()
        }
        titleLabel.textAlignment = .left
    }
    
    
}
