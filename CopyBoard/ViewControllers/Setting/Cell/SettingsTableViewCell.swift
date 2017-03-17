//
//  SettingsTableViewCell.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/9.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    static let nib = UINib(nibName: "SettingsTableViewCell", bundle: nil)
    static let reuseId = "settingsTableViewCell"
    static let rowHeight: CGFloat = 82

    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var settingSwitch: UISwitch!
    @IBOutlet weak var settingDetailLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    var filterColorView: UIView? = nil
    
    var switchBlock: (() -> SettingType)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.settingLabel.textColor = AppColors.menuText
        self.settingDetailLabel.textColor = AppColors.menuSecondaryText
        
        self.checkButton.setImage(Icons.done.iconImage(), for: .normal)
        self.checkButton.tintColor = AppColors.appRed
        self.accessoryType = .disclosureIndicator
        
        self.settingSwitch.addTarget(self, action: #selector(self.switchAction(s:)), for: .valueChanged)
    }
    
    func resetFilterColorView() {
        if self.filterColorView == nil {
            let view = UIView()
            view.clipsToBounds = true
            view.layer.cornerRadius = 14
            self.contentView.addSubview(view)
            view.snp.makeConstraints({ maker in
                maker.left.equalToSuperview().offset(16)
                maker.centerY.equalToSuperview()
                maker.height.equalTo(28)
                maker.width.equalTo(28)
            })
            self.filterColorView = view
        }
        
        self.filterColorView!.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func switchAction(s: UISwitch) {
        if let setting = self.switchBlock?() {
            setting.selectedType().valueAction(isOn: s.isOn, selectedType: setting)
        }
    }

}
