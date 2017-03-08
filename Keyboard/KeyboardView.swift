//
//  KeyboardView.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/26.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

let kBottomKeyboardToolViewHeight: CGFloat = 40

class KeyboardView: UIView {
    
    var collectionView: UICollectionView!
    let bottomToolView = UIView()
    var topToolView: UIView? = nil
    
    let nextKeyboardButton = TouchButton(type: .custom)
    let deleteButton = TouchButton(type: .custom)
    let launchAppButton = TouchButton(type: .custom)
    let returnButton = TouchButton(type: .custom)
    let spaceButton = TouchButton(type: .custom)
    let numberButton = TouchButton(type: .custom)
    let saveButton = TouchButton(type: .custom)
    
//    fileprivate var topToolViewIsShow = false
    fileprivate var _numberCollectionView: UICollectionView?
    
    var showNumber: Bool = false {
        didSet {
            self.numberCollectionView(setShow: self.showNumber)
        }
    }
    
    weak var rootView: UIView?
    
    var numberCollectionView: UICollectionView {
        get {
            return self._numberCollectionView ?? self.createCollectionView()
        }
    }
    
    func config(view: UIView) {
        self.rootView = view
        
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
            maker.height.equalTo(kBottomKeyboardToolViewHeight)
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
        self.collectionView.bgClear()
        self.collectionView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalToSuperview().offset(0.5)
            maker.height.equalTo(DKManager.shared.keyboardHeight)
            maker.bottom.equalTo(self.bottomToolView.snp.top)
        }
        
        self.configButtons()
    }
    
    func configTopToolView(view: UIView) {
        let toolView: UIView
        if let tv = self.topToolView {
            toolView = tv
        } else {
            toolView = UIView()
            self.topToolView = toolView
        }
        
        toolView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        
        let label = UILabel()
        toolView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.centerY.equalToSuperview()
        }
        label.textAlignment = .center

        let attrText = NSMutableAttributedString(string: Localized("open"),
                                                 attributes: [NSFontAttributeName: appFont(size: 14), NSForegroundColorAttributeName: UIColor.white])
        
        let t1 = NSAttributedString(string: Localized("fullAccess"),
                                    attributes: [NSFontAttributeName: appFont(size: 14), NSForegroundColorAttributeName: AppColors.faveButton, NSUnderlineStyleAttributeName: 1])
        attrText.append(t1)
        
        let t2 = NSMutableAttributedString(string: Localized("guildOpenFullAccess"),
                                                 attributes: [NSFontAttributeName: appFont(size: 14), NSForegroundColorAttributeName: UIColor.white])
        attrText.append(t2)
        
        label.attributedText = attrText
        
        view.addSubview(toolView)
        toolView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview().offset(-kBottomKeyboardToolViewHeight)
            maker.height.equalTo(36)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.goSettingsAtion))
        toolView.addGestureRecognizer(tap)
    }
    
    func topToolViewShine() {
        let weakSelf = self
        
        UIView.animate(withDuration: 0.25, animations: { 
            UIView.animate(withDuration: 0.5) {
                weakSelf.topToolView?.backgroundColor = UIColor(white: 0, alpha: 0.2)
            }
        }) { (finish) in
            UIView.animate(withDuration: 0.5) {
                weakSelf.topToolView?.backgroundColor = UIColor(white: 0, alpha: 0.6)
            }
        }
    }
    
    func goSettingsAtion() {
        if #available(iOSApplicationExtension 10.0, *) {
            if let url = URL(string: "App-Prefs:root=General&path=Keyboard/KEYBOARDS/com.zhoubo.CopyBoard.Keyboard") {
                UIApplication.mSharedApplication().mOpenURL(url: url)
            }
        } else {
            if let url = URL(string: "prefs:root=General&path=Keyboard/KEYBOARDS/com.zhoubo.CopyBoard.Keyboard") {
                UIApplication.mSharedApplication().mOpenURL(url: url)
            }
        }
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
                btn.tintColor = AppColors.keyboardTint
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
        
        self.bottomToolView.addSubview(self.numberButton)
        self.numberButton.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.left.equalTo(self.launchAppButton.snp.right).offset(inset)
            maker.width.equalTo(side)
            maker.height.equalTo(side)
        }
        buttonConfigBlock(self.numberButton, true)
        self.numberButton.setImage(Icons.number.iconImage(), for: .normal)
        
        self.bottomToolView.addSubview(self.nextKeyboardButton)
        self.nextKeyboardButton.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.left.equalTo(self.numberButton.snp.right).offset(inset)
            maker.width.equalTo(side)
            maker.height.equalTo(side)
        }
        buttonConfigBlock(self.nextKeyboardButton, true)
        self.nextKeyboardButton.setImage(Icons.globle.iconImage(), for: .normal)
        
        self.bottomToolView.addSubview(self.saveButton)
        self.saveButton.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.left.equalTo(self.nextKeyboardButton.snp.right).offset(inset)
            maker.width.equalTo(side)
            maker.height.equalTo(side)
        }
        buttonConfigBlock(self.saveButton, true)
        self.saveButton.setImage(Icons.save.iconImage(), for: .normal)
        
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
            maker.left.equalTo(self.saveButton.snp.right).offset(inset)
            maker.right.equalTo(self.deleteButton.snp.left).offset(-inset)
            maker.height.equalTo(side)
        }
        buttonConfigBlock(self.spaceButton, true)
        self.spaceButton.setImage(Icons.space.iconImage(), for: .normal)
    }
    
    fileprivate func createCollectionView() -> UICollectionView {
        guard let rv = self.rootView else {
            fatalError("keyboard root view = nil")
        }
        let layout = CHTCollectionViewWaterfallLayout()
        let space = DKManager.shared.itemSpace
        layout.minimumInteritemSpacing = space
        layout.minimumColumnSpacing = space
        layout.columnCount = 3
        layout.itemRenderDirection = .leftToRight
        let inset = space * 0.5
        layout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self.collectionView.delegate
        collectionView.dataSource = self.collectionView.dataSource
        collectionView.backgroundColor = UIColor.white
        rv.addSubview(collectionView)
        collectionView.register(NumberCollectionViewCell.nib,
                                forCellWithReuseIdentifier: NumberCollectionViewCell.reuseId)
        collectionView.snp.makeConstraints { maker in
            maker.height.equalTo(DKManager.shared.keyboardHeight)
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalToSuperview().offset(-DKManager.shared.keyboardHeight)
        }
        
        rv.layoutIfNeeded()
        self._numberCollectionView = collectionView
        return collectionView
    }
    
    func configNumberCollectionViewLayout() {
        if let c = self._numberCollectionView {
            c.snp.updateConstraints({ maker in
                maker.height.equalTo(DKManager.shared.keyboardHeight)
            })
        }
    }
    
    func numberCollectionItemSize() -> CGSize {
        let space = DKManager.shared.itemSpace
        guard let rv = self.rootView else {
            fatalError("root view = nil")
        }
        return CGSize(width: (rv.frame.width - space * 4) / 3, height: (DKManager.shared.keyboardHeight - space * 5) / 4)
    }
 
    func numberCollectionView(setShow: Bool) {
        if let rv = self.rootView {
            self.numberCollectionView.snp.updateConstraints({ maker in
                maker.top.equalToSuperview().offset(setShow ? 0.5 : -DKManager.shared.keyboardHeight)
            })
            UIView.animate(withDuration: 0.25, animations: { //[unowned self] in
                rv.layoutIfNeeded()
            })
        }
    }
    
}


