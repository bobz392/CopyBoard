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
    let nextKeyboardButton = TouchButton(type: .system)
    let deleteButton = TouchButton(type: .system)
    let launchAppButton = TouchButton(type: .system)
    
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
            maker.top.equalToSuperview()
            maker.height.equalTo(220)
            maker.bottom.equalTo(self.bottomToolView.snp.top)
        }
        
        self.configButtons()
    }

    fileprivate func configButtons() {
        let inset = DKManager.shared.itemSpace * 0.5
        let side: CGFloat = 36
        let corner: CGFloat = 2
        
        let buttonConfigBlock = { (btn: TouchButton, isImage: Bool) -> Void in
            btn.useTint = false
            btn.bgColor = AppColors.keyboard
            btn.selectedBgColor = UIColor.white
            btn.config(cornerRadius: corner)
            if isImage {
                btn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
                btn.tintColor = UIColor.black
            }
        }
        
        self.bottomToolView.addSubview(self.nextKeyboardButton)
        self.nextKeyboardButton.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.left.equalToSuperview().offset(inset)
            maker.width.equalTo(side)
            maker.height.equalTo(side)
        }
        buttonConfigBlock(self.nextKeyboardButton, true)
//        self.nextKeyboardButton.setImage(Icons.globle.iconImage(), for: .normal)
        
        self.bottomToolView.addSubview(self.launchAppButton)
        self.launchAppButton.snp.makeConstraints { maker in
            maker.right.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.width.equalTo(side)
            maker.height.equalTo(side)
        }
        buttonConfigBlock(self.launchAppButton, true)
//        self.launchAppButton.setImage(Icons.launch.iconImage(), for: .normal)
        
        self.bottomToolView.addSubview(self.deleteButton)
        self.deleteButton.snp.makeConstraints { maker in
            maker.right.equalTo(self.launchAppButton.snp.left).offset(-inset)
            maker.centerY.equalToSuperview()
            maker.width.equalTo(48)
            maker.height.equalTo(side)
        }
        buttonConfigBlock(self.deleteButton, true)
//        self.deleteButton.setImage(Icons.deleteText.iconImage(), for: .normal)
    }
    
}


