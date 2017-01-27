//
//  EditorView.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/20.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit
import SnapKit

class EditorView {
    let editorTextView = UITextView()
    let barView = UIView()
    let closeButton = TintButton(type: .custom)
    let colorButton = TintButton(type: .custom)
    let colorHolderView = UIView()
    let faveButton = FaveButton(frame: CGRect(center: .zero, size: CGSize(width: 34, height: 34)), faveIconNormal: Icons.star.iconImage())
    
    func config(with view: UIView, note: Note, dismissBlock: @escaping () -> Void) {
        self.configBarView(view: view)
        self.configColorView(view: view)
        self.configNote(view: view, content: note.content)

        let weakSelf = self
        let loadingView = PullDismissView { (progress) in
            weakSelf.faveButton.alpha = 1 - progress
            weakSelf.colorButton.alpha = 1 - progress
            weakSelf.closeButton.alpha = 1 - progress
        }
        
        self.editorTextView.dg_addPullToRefreshWithActionHandler({ () -> Void in
            dismissBlock()
        }, loadingView: loadingView)
        
        if let pairColor = AppPairColors(rawValue: note.color)?.pairColor() {
            self.editorTextView.dg_setPullToRefreshFillColor(pairColor.dark)
            self.editorTextView.dg_setPullToRefreshBackgroundColor(pairColor.light)
            self.barView.backgroundColor = pairColor.dark
            view.backgroundColor = pairColor.light
        }
        
        self.faveButton.isSelected = note.favourite
    }
    
    fileprivate func configBarView(view: UIView) {
        view.addSubview(self.barView)
        self.barView.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.height.equalTo(64)
        }

        self.barView.addSubview(self.closeButton)
        self.closeButton.setImage(Icons.bigClear.iconImage(), for: .normal)
        self.closeButton.addTintColor()
        self.closeButton.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview().offset(10)
            maker.height.equalTo(32)
            maker.width.equalTo(32)
            maker.left.equalToSuperview().offset(12)
        }

        self.barView.addSubview(self.faveButton)
        self.faveButton.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview().offset(10)
            maker.height.equalTo(32)
            maker.width.equalTo(32)
            maker.right.equalToSuperview().offset(-12)
        }
        self.faveButton.normalColor = UIColor.white
        self.faveButton.selectedColor = AppColors.faveButton
        self.faveButton.dotFirstColor = UIColor(red:0.99, green:0.65, blue:0.17, alpha:1.00)
        self.faveButton.dotSecondColor = UIColor(red:0.98, green:0.41, blue:0.22, alpha:1.00)
    }

    fileprivate func configColorView(view: UIView) {
        view.addSubview(self.colorButton)
        self.colorButton.setImage(Icons.color.iconImage(), for: .normal)
        self.colorButton.addTintColor()
        self.colorButton.snp.makeConstraints { maker in
            maker.centerY.equalTo(self.faveButton)
            maker.height.equalTo(self.faveButton)
            maker.width.equalTo(self.faveButton)
            maker.right.equalTo(self.faveButton.snp.left).offset(-12)
        }

        self.colorHolderView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        self.colorHolderView.alpha = 0
        self.colorHolderView.isHidden = true
    }
    
    fileprivate func configNote(view: UIView, content: String) {
        view.addSubview(editorTextView)
//        self.editorTextView.spliteLineColor = AppColors.horizonLine
//        self.editorTextView.font = self.editorTextView.noteFont
        self.editorTextView.bgClear()
        self.editorTextView.textColor = AppColors.noteText
        self.editorTextView.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12)
        self.editorTextView.alwaysBounceVertical = true

        self.editorTextView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalTo(self.barView.snp.bottom)
            maker.bottom.equalToSuperview()
        }

        let attrString = NSMutableAttributedString(string: content)
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = NoteTextView.NoteLineSpace
//        paraStyle.minimumLineHeight = self.editorTextView.noteFont.lineHeight
//        paraStyle.maximumLineHeight = self.editorTextView.noteFont.lineHeight
        
        attrString.addAttributes([
            NSParagraphStyleAttributeName: paraStyle,
            NSFontAttributeName: appFont(size: 18),
            NSForegroundColorAttributeName: AppColors.noteText
            ], range: NSMakeRange(0, content.characters.count))
        self.editorTextView.attributedText = attrString
    }
    
}

final class TintButton: UIButton {
    func addTintColor() {
        self.tintColor = UIColor.white
        
        self.addTarget(self, action: #selector(self.changesTint), for: .touchDown)
        self.addTarget(self, action: #selector(self.resetTint), for: .touchUpOutside)
        self.addTarget(self, action: #selector(self.resetTint), for: .touchDragOutside)
        self.addTarget(self, action: #selector(self.resetTint), for: .touchUpInside)
        self.addTarget(self, action: #selector(self.resetTint), for: .touchCancel)
    }
    
    func changesTint() {
        self.tintColor = AppColors.faveButton
        self.layoutIfNeeded()
    }
    
    func resetTint() {
        self.tintColor = UIColor.white
        self.layoutIfNeeded()
    }
}
