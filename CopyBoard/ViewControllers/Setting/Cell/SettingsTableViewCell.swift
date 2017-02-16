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
    @IBOutlet weak var settingDetaiLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.settingLabel.textColor = AppColors.menuText
        self.settingDetaiLabel.textColor = AppColors.menuSecondaryText
        self.settingSwitch.isHidden = true
        self.settingDetaiLabel.isHidden = true
        
        self.accessoryType = .disclosureIndicator
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configDetailItem(item: SettingDetialType, row: Int) {
        self.settingLabel.text = item.settingName()
    }
    
}
