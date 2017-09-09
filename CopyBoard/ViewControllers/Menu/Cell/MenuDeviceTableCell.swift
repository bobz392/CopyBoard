//
//  MenuDeviceTableCell.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/7.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class MenuDeviceTableCell: UITableViewCell {

    static let nib = UINib(nibName: "MenuDeviceTableCell", bundle: nil)
    static let reuseId = "menuDeviceTableCell"
    static let rowHeight: CGFloat = 58
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.infoLabel.textColor = AppColors.menuText
        self.titleLabel.textColor = AppColors.menuSecondaryText
        
        self.bgClear()
        self.contentView.bgClear()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(row: Int, note: Note) {
        if row == 1 {
            self.infoLabel.text = note.modificationDevice
            self.titleLabel.text = Localized("modificationDevice")
        } else if row == 2 {
            self.infoLabel.text = (note.createdAt ?? Date()).string(custom: "yyyy-MM-dd hh:mm a")
            self.titleLabel.text = Localized("creationDate").uppercased()
        } else {
            self.infoLabel.text = note.category ?? Localized("defaultCatelogue")
            self.titleLabel.text = Localized("catelogue")
        }
    }
}
