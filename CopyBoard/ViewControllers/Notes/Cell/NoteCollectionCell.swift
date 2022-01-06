//
//  NoteCollectionCell.swift
//  CopyBoard
//
//  Created by zhoubo on 2021/12/27.
//  Copyright © 2021 zhoubo. All rights reserved.
//

import UIKit
import UILibrary

class NoteCollectionCell: UICollectionViewCell {
 
    // MARK: - ui props
    private let cardView: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        v.layer.cornerRadius = 8
        v.backgroundColor = UIColor.dms_white
        v.layer.shadowColor = UIColor.dms_black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowOpacity = 6
        v.layer.shadowRadius = 2
        return v
    }()
    
    private let tagLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.dms_black
        lbl.font = UIFont.systemFont(ofSize: 20,
                                     weight: .medium)
        return lbl
    }()
}
