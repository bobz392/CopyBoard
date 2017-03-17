//
//  SegmentationCollectionViewCell.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/3/17.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

let kSegmentationCellHeight: CGFloat = 24
let kSegmentationFontSize: CGFloat = 15

class SegmentationCollectionViewCell: UICollectionViewCell {

    static let nib = UINib(nibName: "SegmentationCollectionViewCell", bundle: nil)
    static let reuseId = "segmentationCollectionViewCell"
    
    @IBOutlet weak var wordLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        self.bgClear()
        self.wordLabel.font = appFont(size: kSegmentationFontSize)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.wordLabel.layer.cornerRadius = kSegmentationCellHeight * 0.5
        self.wordLabel.layer.borderWidth = 1
    }
    
    func configCellUseItem(segmenttation: SegmenttationItem) {
        self.wordLabel.text = segmenttation.content
        let color = segmenttation.inUse ? AppColors.menuText : AppColors.menuSecondaryText
        self.wordLabel.layer.borderColor = color.cgColor
        self.wordLabel.textColor = color
        self.layoutSubviews()
    }
    
}
