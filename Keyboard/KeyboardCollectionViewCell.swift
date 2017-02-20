//
//  KeyboardCollectionViewCell.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/19.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class KeyboardCollectionViewCell: UICollectionViewCell {

    static let nib = UINib(nibName: "KeyboardCollectionViewCell", bundle: nil)
    static let reuseId = "keyboardCollectionViewCell"
    
    @IBOutlet weak var noteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
