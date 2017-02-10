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
    var catView: UIView? = nil
    
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
    
    func catHeaderView() -> UIView {
        if let view = self.catView {
            return view
        } else {
            let catView = UIView()
            let view = UIView()
            catView.addSubview(view)
            view.snp.makeConstraints({ maker in
                maker.left.equalToSuperview().offset(16)
                maker.right.equalToSuperview().offset(-16)
                maker.top.equalToSuperview().offset(5)
                maker.bottom.equalToSuperview().offset(-15)
            })
            view.clipsToBounds = true
            view.layer.cornerRadius = 8
//            view.layer.borderWidth = 0.5
//            view.layer.borderColor = AppColors.mainIcon.cgColor
            
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
            catView.addSubview(touchButton)
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
    
}

struct SettingItem {
    var settingName: String
    var settingType: Int
}

