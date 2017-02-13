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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.settingLabel.textColor = AppColors.menuText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
