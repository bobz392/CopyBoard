//
//  EditorView.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/20.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class EditorView {
    let editorTextView = UITextView()
    let barView = UIView()
    
    let faveButton = FaveButton(frame: CGRect(center: .zero, size: CGSize(width: 38, height: 38)), faveIconNormal: Icons.star.iconImage())
    
    func config(withView view: UIView, note: Note) {
        self.configBarView(view: view)
        
        view.addSubview(editorTextView)
//        self.editorTextView.spliteLineColor = AppColors.horizonLine
//        self.editorTextView.font = self.editorTextView.noteFont
        self.editorTextView.bgClear()
        self.editorTextView.textColor = AppColors.noteText
        self.editorTextView.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12)
        self.editorTextView.alwaysBounceVertical = true
        
//        let loadingView = DGElasticPullToRefreshLoadingView()
//        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
//        self.editorTextView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
//            self?.editorTextView.dg_stopLoading()
//            self?.editorTextView.dg_removePullToRefresh()
//            }, loadingView: loadingView)
//        if let pairColor = AppPairColors(rawValue: note.color)?.pairColor() {
//            self.editorTextView.dg_setPullToRefreshFillColor(pairColor.dark)
//            self.editorTextView.dg_setPullToRefreshBackgroundColor(pairColor.light)
//        }
        
        self.editorTextView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.barView.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }
    
    func configBarView(view: UIView) {
        view.addSubview(self.barView)
        self.barView.backgroundColor = UIColor.yellow
        self.barView.clipsToBounds = true
        self.barView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(64)
        }
        
        self.barView.addSubview(self.faveButton)
        self.faveButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(10)
            make.height.equalTo(32)
            make.width.equalTo(32)
            make.right.equalToSuperview().offset(-12)
        }
        self.faveButton.normalColor = UIColor.white
        self.faveButton.selectedColor = UIColor(red:0.99, green:0.67, blue:0.26, alpha:1.00)
        self.faveButton.dotFirstColor = UIColor(red:0.99, green:0.65, blue:0.17, alpha:1.00)
        self.faveButton.dotSecondColor = UIColor(red:0.98, green:0.41, blue:0.22, alpha:1.00)        
    }
    
    func configNote(content: String) {
        let attrString = NSMutableAttributedString(string: content)
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = NoteTextView.NoteLineSpace
//        paraStyle.minimumLineHeight = self.editorTextView.noteFont.lineHeight
//        paraStyle.maximumLineHeight = self.editorTextView.noteFont.lineHeight
        
        attrString.addAttributes([
            NSParagraphStyleAttributeName: paraStyle,
            NSFontAttributeName: appFont(size: 18)
            ], range: NSMakeRange(0, content.characters.count))
        self.editorTextView.attributedText = attrString
        
        self.editorTextView.alpha = 0
        UIView.animate(withDuration: noteViewShowAlphaAnimation) { [unowned self] in
            self.editorTextView.alpha = 1
        }
    }
    
}
