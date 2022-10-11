//
//  NotePreviewCell.swift
//  CopyBoard
//
//  Created by Bob Zhou on 2022/10/4.
//  Copyright © 2022 zhoubo. All rights reserved.
//

import UIKit
import UILibrary

class NotePreviewCell: UICollectionViewCell {
    
    static let reuseId = "NotePreviewCell"
    
    let cardView: UIView = {
        let v = UIView()
//        v.layer.cornerRadius = 3
        v.backgroundColor = .dms_background
//        v.layer.shadowColor = UIColor.alphaBlack(0.05)
//        v.layer.shadowOffset = .zero
//        v.layer.shadowRadius = 10
//        v.layer.shadowOpacity = 7
        v.layer.uilib_applyShadow(color: UIColor.alphaBlack(0.05),
                                  blur: 4, spread: 3)
        
        return v
    }()
    
    let lastEditLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .dms_grayLight
        lbl.font = UIFont.systemFont(ofSize: 12)
        return lbl
    }()
    
    let tagLabel: PaddingLabel = {
        let lbl = PaddingLabel()
        lbl.paddingRight = 16
        lbl.paddingLeft = 16
        lbl.textColor = UIColor.black
//        lbl.layer.cornerRadius = 2
        lbl.layer.uilib_applyShadow(color: UIColor.alphaBlack(0.2),
                                    y: 3, blur: 5)
        return lbl
    }()
    
    let previewLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .dms_black
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.numberOfLines = 2
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()
    
    let starButton: FaveButton = {
        let btn = FaveButton(frame: .zero, faveIconNormal: UIImage(named: "star"))
        btn.selectedColor = .dms_hexColor(darkHex: 0xFFAC33, lightHex: 0xFFAC33)
        btn.normalColor = .dms_hexColor(darkHex: 0xECF0F2, lightHex: 0xECF0F2)
        btn.dotSecondColor = .dms_hexColor(darkHex: 0xFC672E, lightHex: 0xFC672E)
        btn.dotFirstColor = .dms_hexColor(darkHex: 0xFEA707, lightHex: 0xFEA707)
        return btn
    }()
    
    // MARK: - life circle
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addContent()
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ui
    private func addContent() {
        contentView.addSubview(cardView)
        contentView.addSubview(tagLabel)
        cardView.addSubview(starButton)
        cardView.addSubview(lastEditLabel)
        cardView.addSubview(previewLabel)
    }
    
    private func buildLayout() {
        let tagHeight: CGFloat = 26
        let topPadding: CGFloat = 10
        cardView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            // top padding 10 + tag label height * 0.5
            make.top.equalToSuperview().offset(topPadding + tagHeight * 0.5)
            make.bottom.equalToSuperview()
        }
        tagLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(37)
            make.top.equalToSuperview().offset(topPadding)
            make.height.equalTo(tagHeight)
        }
        lastEditLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(21)
            make.top.equalToSuperview().offset(8 + tagHeight * 0.5)
        }
        previewLabel.snp.makeConstraints { make in
            make.left.equalTo(lastEditLabel)
            make.top.equalTo(lastEditLabel.snp.bottom).offset(4)
        }
        starButton.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerY.equalTo(lastEditLabel)
            make.right.equalToSuperview().offset(-21)
        }
    }
    
}
