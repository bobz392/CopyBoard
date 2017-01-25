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
    
    func config(withView view: UIView) {
        self.configBarView(view: view)
        
        view.addSubview(editorTextView)
//        self.editorTextView.spliteLineColor = AppColors.horizonLine
//        self.editorTextView.font = self.editorTextView.noteFont
        self.editorTextView.bgClear()
        self.editorTextView.textColor = AppColors.noteText
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
    }
    
    func configNote(content: String) {
        let attrString = NSMutableAttributedString(string: content)
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = NoteTextView.NoteLineSpace
//        paraStyle.minimumLineHeight = self.editorTextView.noteFont.lineHeight
//        paraStyle.maximumLineHeight = self.editorTextView.noteFont.lineHeight
        
        attrString.addAttributes([
            NSParagraphStyleAttributeName: paraStyle,
            NSFontAttributeName: appFont(size: 16)
            ], range: NSMakeRange(0, content.characters.count))
        self.editorTextView.attributedText = attrString
        
        self.editorTextView.alpha = 0
        
        UIView.animate(withDuration: 0.1) { [unowned self] in
            self.editorTextView.alpha = 1
        }
    }
    
}
