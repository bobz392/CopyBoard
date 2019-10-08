//
//  MenuDateTableCell.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/6.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class MenuDateTableCell: UITableViewCell {
    
    static let nib = UINib(nibName: "MenuDateTableCell", bundle: nil)
    static let reuseId = "menuDateTableCell"
    static let rowHeight: CGFloat = 82
    
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var editLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.dayLabel.textColor = AppColors.menuText
        self.dateLabel.textColor = AppColors.menuText
        self.editLabel.textColor = AppColors.menuSecondaryText
        
        self.bgClear()
        self.contentView.bgClear()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configEditDate(date: Date) {
        self.dayLabel.text = "\(date.day)"
        
        self.dateLabel.text = date.toString(.custom("MMMM YYYY HH:mm"))
        self.editLabel.text = Localized("modificationDate").uppercased()
    }
    
}
