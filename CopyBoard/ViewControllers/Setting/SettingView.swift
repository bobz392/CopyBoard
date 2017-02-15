//
//  SettingView.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/9.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

let kSettingMargin: CGFloat = 16

class SettingView {
    
    let realBarView = BarView()
    let closeButton = UIButton(type: .custom)
    let backButton = UIButton(type: .custom)
    
    let settingsTableView = UITableView(frame: .zero, style: .grouped)
    var catView: UIView? = nil
    
    func config(view: UIView) {
        view.backgroundColor = AppColors.cloud
        self.configTableView(view: view)
        self.configBarView(view: view)
    }
    
    func configBarView(view: UIView) {
        view.addSubview(self.realBarView)
        self.realBarView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalToSuperview().offset(DeviceManager.shared.statusbarHeight)
            maker.height.equalTo(DeviceManager.shared.navigationBarHeight)
        }
        self.realBarView.backgroundColor = AppColors.cloudHeader
        self.realBarView.titleLabel.text = Localized("settings")
        self.realBarView.addTableViewIndexCover(color: AppColors.cloud)
        
        let topView = UIView()
        topView.backgroundColor = AppColors.cloudHeader
        view.addSubview(topView)
        topView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.height.equalTo(20)
            maker.bottom.equalTo(self.realBarView.snp.top)
        }
        
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
        let height = DeviceManager.shared.navigationBarHeight + DeviceManager.shared.statusbarHeight
        self.settingsTableView.contentInset =
            UIEdgeInsetsMake(height, 0, 0, 0)
        
        self.settingsTableView.register(SettingsTableViewCell.nib,
                                        forCellReuseIdentifier: SettingsTableViewCell.reuseId)
        self.settingsTableView.separatorColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.00)
        self.settingsTableView.bgClear()
    }
    
    func configTableView<T: UITableViewDelegate, E: UITableViewDataSource>(delegate: T, dataSource: E) {
        self.settingsTableView.delegate = delegate
        self.settingsTableView.dataSource = dataSource
    }
    
    func invalidateLayout() {
        let statusBarHeight = DeviceManager.shared.statusbarHeight
        let barHeight = DeviceManager.shared.navigationBarHeight
        
        self.settingsTableView.contentInset =
            UIEdgeInsetsMake(barHeight + statusBarHeight, 0, 0, 0)
        
        self.realBarView.snp.updateConstraints { maker in
            maker.top.equalToSuperview().offset(statusBarHeight)
            maker.height.equalTo(barHeight)
        }
        self.realBarView.superview?.layoutIfNeeded()
        
        if let firstCell = self.settingsTableView.visibleCells.first,
            let index = self.settingsTableView.indexPath(for: firstCell) {
            self.settingsTableView.scrollToRow(at: index, at: .top, animated: false)
        }
    }
    
    // MARK: - detail setting
    func configSettingDetail(title: String) {
        self.realBarView.titleLabel.text = title
        self.realBarView.appendButtons(buttons: [self.backButton], left: true)
        self.backButton.setImage(Icons.back.iconImage(), for: .normal)
        self.backButton.tintColor = AppColors.mainIcon
    }
    
}

extension SettingView {
    
    func catHeaderView() -> UIView {
        if let view = self.catView {
            return view
        } else {
            let catView = UIView()
            let view = UIView()
            catView.addSubview(view)
            view.snp.makeConstraints({ maker in
                maker.left.equalToSuperview().offset(kSettingMargin)
                maker.right.equalToSuperview().offset(-kSettingMargin)
                maker.top.equalToSuperview().offset(5)
                maker.bottom.equalToSuperview().offset(-20)
            })
            view.clipsToBounds = true
            view.layer.cornerRadius = 8
            
            let imageView = UIImageView()
            imageView.image = UIImage(named: "cat")
            imageView.contentMode = .scaleAspectFill
            view.addSubview(imageView)
            imageView.snp.makeConstraints({ maker in
                maker.top.equalToSuperview()
                maker.left.equalToSuperview()
                maker.right.equalToSuperview()
            })
            
            let label = UILabel()
            view.addSubview(label)
            label.text = "USE KEYBOARD"
            label.textColor = UIColor.white
            label.backgroundColor = UIColor(red:0.86, green:0.30, blue:0.32, alpha:1.00)
            label.textAlignment = .center
            view.addSubview(label)
            label.snp.makeConstraints({ maker in
                maker.left.equalToSuperview()
                maker.right.equalToSuperview()
                maker.bottom.equalToSuperview()
                maker.height.equalTo(38)
                maker.top.equalTo(imageView.snp.bottom)
            })
            
            let touchButton = TouchButton(type: .custom)
            touchButton.config(cornerRadius: 0)
            touchButton.useTint = false
            touchButton.bgColor = UIColor.clear
            touchButton.selectedBgColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:0.8)
            view.addSubview(touchButton)
            touchButton.snp.makeConstraints({ maker in
                maker.left.equalToSuperview()
                maker.right.equalToSuperview()
                maker.top.equalToSuperview()
                maker.bottom.equalToSuperview()
            })
            
            self.catView = catView
            return catView
        }
    }
    
    func sectionHeaderView(title: String) -> UIView {
        let view = UIView()
        view.bgClear()
        
        let headerLabel = UILabel()
        headerLabel.text = title
        headerLabel.textColor = AppColors.menuSecondaryText
        headerLabel.font = appFont(size: 15)
        view.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { maker in
            maker.left.equalTo(kSettingMargin)
            maker.bottom.equalTo(-5)
        }
        
        return view
    }
    
}
