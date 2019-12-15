//
//  SettingView.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/9.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

let kSettingMargin: CGFloat = 16
let kCatHeaderImageBottomPadding: CGFloat = 25
let kCatHeaderViewHeight: CGFloat =
    0.334 * max(UIScreen.main.bounds.height, UIScreen.main.bounds.width) + kCatHeaderImageBottomPadding
let kVersionFooterViewHeight: CGFloat = 65
let kNormalHeaderViewHeight: CGFloat = 40

let kFooterViewHeight: CGFloat = 40
let kFooterViewContentTopPadding: CGFloat = 4

let kSettingItemHeight: CGFloat = 50

class SettingView {
    
    let realBarView = BarView()
    let closeButton = UIButton(type: .custom)
    let backButton = UIButton(type: .custom)
    let catGuideButton = TouchButton(type: .system)
    
    let settingsTableView = UITableView(frame: .zero, style: .grouped)
    var catView: UIView? = nil
    var bottomView: UIView? = nil
    
    func config(view: UIView) {
        view.backgroundColor = AppColors.cloud
        
        configTableView(view: view)
        configBarView(view: view)
    }
    
    func configBarView(view: UIView) {
        view.addSubview(realBarView)
        realBarView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalToSuperview()
                .offset(DeviceManager.shared.statusbarHeight)
            maker.height
                .equalTo(DeviceManager.shared.navigationBarHeight)
        }
        realBarView.backgroundColor = AppColors.cloudHeader
        realBarView.titleLabel.text = Localized("settings")
        realBarView.addTableViewIndexCover(color: AppColors.cloud)
        
        let topView = UIView()
        topView.backgroundColor = AppColors.cloudHeader
        view.addSubview(topView)
        topView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.height.equalTo(20)
            maker.bottom.equalTo(self.realBarView.snp.top)
        }
        
        realBarView.appendButtons(buttons: [closeButton],
                                  left: false)
        closeButton.setImage(Icons.done.iconImage(),
                             for: .normal)
        closeButton.contentHorizontalAlignment = .fill
        closeButton.contentVerticalAlignment = .fill
        
        let insets: CGFloat = 5
        closeButton.contentEdgeInsets =
            UIEdgeInsets(top: insets, left: 0,
                         bottom: insets, right: 0)
        closeButton.tintColor = AppColors.mainIcon
    }
    
    fileprivate func configTableView(view: UIView) {
        view.addSubview(settingsTableView)
        settingsTableView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
        let height = DeviceManager.shared.navigationBarHeight + DeviceManager.shared.statusbarHeight
        settingsTableView.contentInset =
            UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
        
        settingsTableView
            .register(SettingsTableViewCell.nib,
                      forCellReuseIdentifier: SettingsTableViewCell.reuseId)
        settingsTableView.separatorColor =
            UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.00)
        settingsTableView.bgClear()
    }
    
    func configTableView<T: UITableViewDelegate, E: UITableViewDataSource>(delegate: T, dataSource: E) {
        settingsTableView.delegate = delegate
        settingsTableView.dataSource = dataSource
    }
    
    func invalidateLayout() {
        let statusBarHeight = DeviceManager.shared.statusbarHeight
        let barHeight = DeviceManager.shared.navigationBarHeight
        
        settingsTableView.contentInset =
            UIEdgeInsets(top: barHeight + statusBarHeight, left: 0, bottom: 0, right: 0)
        
        self.realBarView.snp.updateConstraints { maker in
            maker.top.equalToSuperview().offset(statusBarHeight)
            maker.height.equalTo(barHeight)
        }
        realBarView.superview?.layoutIfNeeded()
        
        if let firstCell = settingsTableView.visibleCells.first,
            let index = settingsTableView.indexPath(for: firstCell) {
            settingsTableView
                .scrollToRow(at: index, at: .top, animated: false)
        }
    }
    
    // MARK: - detail setting
    func configSettingDetail(title: String) {
        realBarView.titleLabel.text = title
        realBarView.appendButtons(buttons: [backButton],
                                  left: true)
        backButton.setImage(Icons.back.iconImage(),
                            for: .normal)
        backButton.tintColor = AppColors.mainIcon
    }
    
}

extension SettingView {
    
    func catHeaderView() -> UIView {
        if let view = catView {
            return view
        } else {
            let catView = UIView()
            let view = UIView()
            catView.addSubview(view)
            view.snp.makeConstraints({ maker in
                maker.left.equalToSuperview().offset(kSettingMargin)
                maker.right.equalToSuperview().offset(-kSettingMargin)
                maker.top.equalToSuperview().offset(5)
                maker.bottom.equalToSuperview()
                    .offset(-20-kCatHeaderImageBottomPadding)
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
            label.text = Localized("useKeyboard")
            label.textColor = UIColor.white
            label.backgroundColor = AppColors.appRed
            label.clipsToBounds = true
            label.textAlignment = .center
            view.addSubview(label)
            label.snp.makeConstraints({ maker in
                maker.left.equalToSuperview()
                maker.right.equalToSuperview()
                maker.bottom.equalToSuperview()
                maker.height.equalTo(38)
                maker.top.equalTo(imageView.snp.bottom)
            })
            
            catGuideButton.config(cornerRadius: 0)
            catGuideButton.useTint = false
            catGuideButton.bgColor = UIColor.clear
            catGuideButton.selectedBgColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:0.8)
            view.addSubview(catGuideButton)
            catGuideButton.snp.makeConstraints({ maker in
                maker.left.equalToSuperview()
                maker.right.equalToSuperview()
                maker.top.equalToSuperview()
                maker.bottom.equalToSuperview()
            })
            
            let useKeyboardTip = UILabel()
            useKeyboardTip.text = Localized("useKeyboardTip")
            useKeyboardTip.textAlignment = .left
            useKeyboardTip.textColor = AppColors.menuSecondaryText
            useKeyboardTip.numberOfLines = 0
            useKeyboardTip.font = appFont(size: 11)
            catView.addSubview(useKeyboardTip)
            useKeyboardTip.snp.makeConstraints { maker in
                maker.leading.equalTo(kSettingMargin)
                maker.trailing.equalTo(-kSettingMargin)
                maker.bottom.equalToSuperview().offset(-10)
            }
            
            self.catView = catView
            return catView
        }
    }
    
    func versionFooterView() -> UIView {
        if let footer = self.bottomView {
            return footer
        } else {
            let footer = UIView()
            footer.bgClear()
            
            let versionLabel = UILabel()
            footer.addSubview(versionLabel)
            versionLabel.textAlignment = .center
            versionLabel.font = appFont(size: 14)
            versionLabel.textColor = AppColors.menuSecondaryText
            versionLabel.text = "\(Localized("version")) \(AppSettings.shared.version)"
            versionLabel.snp.makeConstraints({ maker in
                maker.centerX.equalToSuperview()
                maker.top.equalToSuperview().offset(40)
            })
            
            self.bottomView = footer
            return footer
        }
    }
    
    func sectionHeaderView(title: String) -> UIView {
        let view = UIView()
        view.bgClear()
        
        let headerLabel = UILabel()
        headerLabel.text = title
        headerLabel.textColor = AppColors.menuSecondaryText
        headerLabel.font = appFont(size: 14)
        view.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { maker in
            maker.left.equalTo(kSettingMargin)
            maker.bottom.equalTo(-5)
        }
        
        return view
    }
    
    func sectionFooterView(title: String) -> UIView {
        let view = UIView()
        view.bgClear()
        
        let footerLabel = UILabel()
        footerLabel.text = title
        footerLabel.textAlignment = .left
        footerLabel.textColor = AppColors.menuSecondaryText
        footerLabel.numberOfLines = 0
        footerLabel.font = appFont(size: 11)
        view.addSubview(footerLabel)
        footerLabel.snp.makeConstraints { maker in
            maker.leading.equalTo(kSettingMargin)
            maker.trailing.equalTo(-kSettingMargin)
            maker.top.equalTo(kFooterViewContentTopPadding)
        }
        
        return view
    }
}

// MAKR: - keyboard
extension SettingView {
    
}
