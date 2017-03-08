
//  NumberCollectionViewCell.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/3/8.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class NumberCollectionViewCell: UICollectionViewCell {
    
    static let nib = UINib(nibName: "NumberCollectionViewCell", bundle: nil)
    static let reuseId = "numberCollectionViewCell"
    
    @IBOutlet weak var numberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.numberLabel.textColor = AppColors.keyboardTint
        self.numberLabel.font = appFont(size: 20, weight: UIFontWeightMedium)
        self.backgroundColor = AppColors.keyboard
    }

}
