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
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.settingLabel.textColor = AppColors.menuText
        self.settingDetailLabel.textColor = AppColors.menuSecondaryText
        
        self.checkButton.setImage(Icons.done.iconImage(), for: .normal)
        self.checkButton.tintColor = AppColors.red
        self.accessoryType = .disclosureIndicator
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configDetailItem(item: SettingType, row: Int, section: Int) {
        item.detailSettingConfig(cell: self, row: row, section: section)
    }
    
    func configSettingItem(item: SettingType) {
        self.settingLabel.text = item.settingName()
        self.accessoryType = item == .version ? .none : .disclosureIndicator
        self.settingDetailLabel.isHidden = item != .version
        self.settingDetailLabel.text = item == .version ? AppSettings.shared.version : nil
    }

}
