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
    let faveButton = FaveButton(frame: .zero, faveIconNormal: Icons.star.iconImage())
    
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
        
        self.barView.addSubview(self.faveButton)
        self.faveButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(10)
            make.height.equalTo(32)
            make.width.equalTo(32)
            make.right.equalToSuperview().offset(-8)
        }
        self.faveButton.normalColor = UIColor.white
        self.faveButton.selectedColor = UIColor(colorLiteralRed: 226/255, green: 38/255,  blue: 77/255,  alpha: 1)

        self.faveButton.dotFirstColor = UIColor(colorLiteralRed: 152/255, green: 219/255, blue: 236/255, alpha: 1)

        self.faveButton.dotSecondColor = UIColor(colorLiteralRed: 247/255, green: 188/255, blue: 48/255,  alpha: 1)
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
        
        UIView.animate(withDuration: kNoteViewAlphaAnimation) { [unowned self] in
            self.editorTextView.alpha = 1
        }
    }
    
}
