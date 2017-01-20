//
//  NoteTableViewCell.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/19.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class NoteTableViewCell: MGSwipeTableCell {

    static let nib = UINib(nibName: "NoteTableViewCell", bundle: nil)
    static let reuseId = "noteTableViewCell"
    static let rowHeight: CGFloat = 75
    
    @IBOutlet weak var cellCardView: UIView!
    @IBOutlet weak var horizonLineView: UIView!
    @IBOutlet weak var verticalLineView: UIView!
    @IBOutlet weak var verticalLineView2: UIView!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var noteDateLabel: UILabel!
    
    let clipImageView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.bgClear()
        self.contentView.bgClear()
        self.cellCardView.addCardShadow()
        self.noteLabel.textColor = AppColors.noteText
        self.noteDateLabel.textColor = AppColors.noteDate
        
        AppColors.noteCell.bgColor(to: self.cellCardView)
        AppColors.horizonLine.bgColor(to: self.horizonLineView)
        AppColors.verticalLine.bgColor(to: self.verticalLineView)
        AppColors.horizonLine.bgColor(to: self.verticalLineView2)
        
        self.addSubview(self.clipImageView)
        self.clipImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(26)
            make.height.equalTo(66)
            make.centerY.equalToSuperview()
        }
        self.clipImageView.image = UIImage(named: "clip")
        self.clipImageView.highlightedImage = UIImage(named: "clip_p")
        
        self.rightSwipeSettings.transition = .drag
        self.rightSwipeSettings.topMargin = 5
        self.rightSwipeSettings.bottomMargin = 10
        self.touchOnDismissSwipe = false
        
        self.delegate = self
        self.rightExpansion.buttonIndex = 0
        self.rightExpansion.fillOnTrigger = true
        
        let button = MGSwipeButton(title: "Delete", backgroundColor: AppColors.swipeRedBackgroundColor)
        button.callback = { [unowned self] (cell) -> Bool in
            self.deleteAction()
            return false
        }
        self.rightButtons = [button]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func deleteAction() {
        print("note delete")
        print(self.swipeState.rawValue)
    }
    
}

extension NoteTableViewCell: MGSwipeTableCellDelegate {
    
    func swipeTableCell(_ cell: MGSwipeTableCell, didChange state: MGSwipeState, gestureIsActive: Bool) {
        self.clipImageView.isHighlighted = state != .none
        
//        MGSwipeStateNone = 0,
//        MGSwipeStateSwipingLeftToRight,
//        MGSwipeStateSwipingRightToLeft,
//        MGSwipeStateExpandingLeftToRight,
//        MGSwipeStateExpandingRightToLeft,
    }
}
