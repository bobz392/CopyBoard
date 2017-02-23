//
//  KeyboardView.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/26.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class KeyboardView: UIView {
    
    var collectionView: UICollectionView!
    let bottomToolView = UIView()
    let nextKeyboardButton = TouchButton(type: .custom)
    let deleteButton = TouchButton(type: .custom)
    let launchAppButton = TouchButton(type: .custom)
    let returnButton = TouchButton(type: .custom)
    let spaceButton = TouchButton(type: .custom)
    let previewButton = UIButton(type: .system)
    
    func config(view: UIView) {
        let lineView = UIView()
        view.addSubview(lineView)
        lineView.backgroundColor = UIColor.lightGray
        lineView.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.height.equalTo(0.5)
        }
        
        view.addSubview(self.bottomToolView)
        self.bottomToolView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.height.equalTo(40)
        }
        
        let layout = CHTCollectionViewWaterfallLayout()
        let space = DKManager.shared.itemSpace
        
        layout.minimumInteritemSpacing = space
        layout.minimumColumnSpacing = space
        layout.columnCount = DKManager.shared.columnCount
        layout.itemRenderDirection = .shortestFirst
        let inset = space * 0.5
        layout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset)
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.delaysContentTouches = false
        self.collectionView.register(KeyboardCollectionViewCell.nib,
                                     forCellWithReuseIdentifier: KeyboardCollectionViewCell.reuseId)
        
        view.addSubview(self.collectionView)
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalToSuperview().offset(0.5)
            maker.height.equalTo(DKManager.shared.keyboardHeight)
            maker.bottom.equalTo(self.bottomToolView.snp.top)
        }
        
        self.configButtons()
    }
    
    fileprivate func configButtons() {
        let inset = DKManager.shared.itemSpace
        let side: CGFloat = 34
        let corner: CGFloat = 2
        
        let buttonConfigBlock = { (btn: TouchButton, isImage: Bool) -> Void in
            btn.useTint = false
            btn.bgColor = AppColors.keyboard
            btn.selectedBgColor = UIColor.white
            btn.config(cornerRadius: corner)
            let imageInset: CGFloat = 6
            if isImage {
                btn.imageEdgeInsets = UIEdgeInsetsMake(imageInset, imageInset, imageInset, imageInset)
                btn.tintColor = UIColor.black
            }
        }
        
        self.bottomToolView.addSubview(self.launchAppButton)
        self.launchAppButton.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(inset)
            maker.centerY.equalToSuperview()
            maker.width.equalTo(side)
            maker.height.equalTo(side)
        }
        buttonConfigBlock(self.launchAppButton, true)
        self.launchAppButton.setImage(Icons.launch.iconImage(), for: .normal)
        
        self.bottomToolView.addSubview(self.nextKeyboardButton)
        self.nextKeyboardButton.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.left.equalTo(self.launchAppButton.snp.right).offset(inset)
            maker.width.equalTo(side)
            maker.height.equalTo(side)
        }
        buttonConfigBlock(self.nextKeyboardButton, true)
        self.nextKeyboardButton.setImage(Icons.globle.iconImage(), for: .normal)
        
        self.bottomToolView.addSubview(self.previewButton)
        self.previewButton.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.left.equalTo(self.nextKeyboardButton.snp.right).offset(inset)
            maker.width.equalTo(side)
            maker.height.equalTo(side)
        }
        self.previewButton.adjustsImageWhenHighlighted = false
        self.previewButton.backgroundColor = AppColors.keyboard
        self.previewButton.layer.cornerRadius = corner
        self.previewButton.setImage(Icons.preview.iconImage(), for: .normal)
        self.previewButton.tintColor = UIColor.black
        
        self.bottomToolView.addSubview(self.returnButton)
        self.returnButton.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-inset)
            maker.centerY.equalToSuperview()
            maker.width.equalTo(48)
            maker.height.equalTo(side)
        }
        buttonConfigBlock(self.returnButton, true)
        self.returnButton.setImage(Icons.returnKey.iconImage(), for: .normal)
        
        self.bottomToolView.addSubview(self.deleteButton)
        self.deleteButton.snp.makeConstraints { maker in
            maker.right.equalTo(self.returnButton.snp.left).offset(-inset)
            maker.centerY.equalToSuperview()
            maker.width.equalTo(48)
            maker.height.equalTo(side)
        }
        buttonConfigBlock(self.deleteButton, true)
        self.deleteButton.setImage(Icons.deleteText.iconImage(), for: .normal)
        
        self.bottomToolView.addSubview(self.spaceButton)
        self.spaceButton.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.left.equalTo(self.previewButton.snp.right).offset(inset)
            maker.right.equalTo(self.deleteButton.snp.left).offset(-inset)
            maker.height.equalTo(side)
        }
        buttonConfigBlock(self.spaceButton, true)
        self.spaceButton.setImage(Icons.space.iconImage(), for: .normal)
    }
    
}


