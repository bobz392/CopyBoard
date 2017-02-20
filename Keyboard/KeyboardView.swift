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
        
        self.bottomToolView.addSubview(self.nextKeyboardButton)
        self.nextKeyboardButton.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.left.equalToSuperview().offset(inset)
            maker.width.equalTo(36)
            maker.height.equalTo(36)
        }
        self.nextKeyboardButton.useTint = false
        self.nextKeyboardButton.bgColor = AppColors.keyboard
        self.nextKeyboardButton.selectedBgColor = UIColor.white
        self.nextKeyboardButton.config(cornerRadius: 2)
        self.nextKeyboardButton.setImage(Icons.globle.iconImage(), for: .normal)
        self.nextKeyboardButton.tintColor = AppColors.mainIcon
    }

}


