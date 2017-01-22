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
//    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var noteContentView: ZCFocusLabel!
    @IBOutlet weak var faveButton: FaveButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.noteContentView.animationDuration = 0.1
        self.noteContentView.animationDelay = 0.01
    }

    func configCell(use note: Note) {
        guard let pairColor = AppPairColors(rawValue: note.color)?.pairColor() else {
            fatalError("have no this type color")
        }
        pairColor.dark.bgColor(to: self.headerView)
        pairColor.light.bgColor(to: self.cardView)
        self.noteContentView.text = note.content
        
        self.noteContentView.startAppearAnimation()
        
//        self.noteContentView.textColor = AppColors.noteText
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 3
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.backgroundColor = UIColor.clear.cgColor
    }
    
}
