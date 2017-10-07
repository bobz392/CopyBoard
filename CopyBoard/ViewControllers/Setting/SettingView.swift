//
//  SettingView.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/9.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

let kSettingMargin: CGFloat = 16
let kCatHeaderViewHeight: CGFloat = 190
let kVersionFooterViewHeight: CGFloat = 65
let kNormalHeaderViewHeight: CGFloat = 40
let kSettingItemHeight: CGFloat = 50
//let kMinKeyboardHeight: CGFloat = 200
//let kDefaultKeyboardHeight: CGFloat = 258
//let kDefaultKeyboardHeight: CGFloat =

class SettingView {
    
    let realBarView = BarView()
    let closeButton = UIButton(type: .custom)
    let backButton = UIButton(type: .custom)
    
    let settingsTableView = UITableView(frame: .zero, style: .grouped)
    var catView: UIView? = nil
    var bottomView: UIView? = nil
    
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
        self.closeButton.contentHorizontalAlignment = .fill
        self.closeButton.contentVerticalAlignment = .fill
        self.closeButton.contentEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6)
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
            label.text = Localized("useKeyboard")
            label.textColor = UIColor.white
            label.backgroundColor = AppColors.appRed
            label.textAlignment = .center
            view.addSubview(label)
            label.snp.makeConstraints({ maker in
                maker.left.equalToSuperview()
                maker.right.equalToSuperview()
                maker.bottom.equalToSuperview()
                maker.height.equalTo(38)
                maker.top.equalTo(imageView.snp.bottom)
            })
            
            let touchButton = TouchButton(type: .system)
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
            touchButton.addTarget(self, action: #selector(self.guildAction), for: .touchUpInside)
            
            self.catView = catView
            return catView
        }
    }
    
    @objc func guildAction() {
        let arrayOfImage = ["step1", "step2", "step3"]
        let local = Localized("step")
        let arrayOfTitle = ["\(local) 1", "\(local) 2", "\(local) 3"]
        let arrayOfDescription = [Localized("description1"), Localized("description2"), Localized("description3")]
        let buttonsTitles = [Localized("doGuild1"), Localized("doGuild2"), Localized("doGuild3")]
        
        let alertView = AlertOnboarding(arrayOfImage: arrayOfImage, arrayOfTitle: arrayOfTitle, arrayOfDescription: arrayOfDescription, arrayOfBottomTitles: buttonsTitles) { (index) in
            
            if index == 0 {
                if #available(iOSApplicationExtension 10.0, *) {
                    if let url = URL(string: "App-Prefs:root=General&path=Keyboard/KEYBOARDS") {
                        UIApplication.shared.openURL(url)
                    }
                } else {
                    if let url = URL(string: "prefs:root=General&path=Keyboard/KEYBOARDS") {
                        UIApplication.shared.openURL(url)
                    }
                }
                return false
            } else if index == 1 {
                if #available(iOSApplicationExtension 10.0, *) {
                    if let url = URL(string: "App-Prefs:root=General&path=Keyboard/KEYBOARDS/com.zhoubo.CopyBoard.Keyboard") {
                        UIApplication.shared.openURL(url)
                    }
                } else {
                    if let url = URL(string: "prefs:root=General&path=Keyboard/KEYBOARDS/com.zhoubo.CopyBoard.Keyboard") {
                        UIApplication.shared.openURL(url)
                    }
                }
                return false
            } else {
                return true
            }
            
            
        }
        
        alertView.show()
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
    
}

// MAKR: - keyboard
extension SettingView {
    
}
