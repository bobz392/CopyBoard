//
//  NoteCollectionViewCell.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/21.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class NoteCollectionViewCell: UICollectionViewCell {

    static let nib = UINib(nibName: "NoteCollectionViewCell", bundle: nil)
    static let reuseId = "noteCollectionViewCell"
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        headerView.backgroundColor = UIColor(red:0.79, green:0.93, blue:0.97, alpha:1.00)
        
        self.backgroundColor = UIColor(red:0.77, green:0.89, blue:0.96, alpha:1.00)
    }

}
