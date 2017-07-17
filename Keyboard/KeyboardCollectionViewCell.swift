//
//  KeyboardCollectionViewCell.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/19.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class KeyboardCollectionViewCell: UICollectionViewCell, CollectionCellHighlight {

    static let nib = UINib(nibName: "KeyboardCollectionViewCell", bundle: nil)
    static let reuseId = "keyboardCollectionViewCell"
    
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    
    fileprivate var cacheColor: UIColor? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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


protocol CollectionCellHighlight {
    func highlight()
    func unhighlight()
}
