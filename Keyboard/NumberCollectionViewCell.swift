
//  NumberCollectionViewCell.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/3/8.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class NumberCollectionViewCell: UICollectionViewCell, CollectionCellHighlight {
    
    static let nib = UINib(nibName: "NumberCollectionViewCell", bundle: nil)
    static let reuseId = "numberCollectionViewCell"
    
    @IBOutlet weak var numberLabel: UILabel!
    fileprivate var cacheColor: UIColor? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.numberLabel.textColor = AppColors.keyboardTint
        self.numberLabel.font = appFont(size: 20, weight: .medium)
        self.backgroundColor = AppColors.keyboard
    }
    
    func highlight() {
        self.cacheColor = self.backgroundColor
        self.backgroundColor = AppColors.cellSelected
        
    }
    
    func unhighlight() {
        UIView.animate(withDuration: 0.4, animations: { [unowned self] in
            self.backgroundColor = self.cacheColor
        })
    }
}
