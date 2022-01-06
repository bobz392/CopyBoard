//
//  NoteCell.swift
//  CopyBoard
//
//  Created by zhoubo on 2022/1/1.
//  Copyright © 2022 zhoubo. All rights reserved.
//

import UIKit

class NoteCell: UICollectionViewCell {
    
    private let cardView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 8
        v.backgroundColor = UIColor.dms_white
        v.layer.shadowColor = UIColor.dms_black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowOpacity = 0.1
        v.layer.shadowRadius = 6
        return v
    }()
    
    private let tagLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .dms_black
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.clipsToBounds = true
        lbl.layer.cornerRadius = 10
        return lbl
    }()
    
    private let contentLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl.textColor = .dms_black
        return lbl
    }()
    
    private let updateLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl.textColor = .dms_grayLight
        return lbl
    }()
    
    private let shareButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(Icons.share.iconImage(), for: .normal)
        return btn
    }()
    let actionsButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(Icons.moreActions.iconImage(), for: .normal)
        return btn
    }()
    private let collectButton: FaveButton = {
        let btn = FaveButton(frame: .zero, faveIconNormal: UIImage(named: "star"))
        btn.selectedColor = .dms_hexColor(darkHex: 0xFFAC33, lightHex: 0xFFAC33)
        btn.normalColor = .dms_hexColor(darkHex: 0xECF0F2, lightHex: 0xECF0F2)
        btn.dotSecondColor = .dms_hexColor(darkHex: 0xFC672E, lightHex: 0xFC672E)
        btn.dotFirstColor = .dms_hexColor(darkHex: 0xFEA707, lightHex: 0xFEA707)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildUI() {
        // 背景带有阴影的 card view
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 卡片内容距离 card view 边框的 padding
        let edgePadding: CGFloat = 12.0
        cardView.addSubview(tagLabel)
        tagLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
                .inset(edgePadding)
            make.height.equalTo(20)
        }
        
        cardView.addSubview(contentLabel)
        contentLabel.numberOfLines = 3
        contentLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
                .inset(edgePadding)
            make.top.equalTo(tagLabel.snp.bottom)
                .offset(8)
        }
        
        cardView.addSubview(collectButton)
        collectButton.snp.makeConstraints { make in
            make.width.height.equalTo(25)
            make.centerY.equalTo(tagLabel)
            make.right.equalToSuperview()
                .inset(edgePadding)
        }
        
        cardView.addSubview(updateLabel)
        updateLabel.snp.makeConstraints { make in
            make.left.equalTo(tagLabel)
            make.bottom.equalToSuperview()
                .inset(edgePadding)
        }
        
        cardView.addSubview(actionsButton)
        actionsButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
                .inset(edgePadding)
            make.centerY.equalTo(updateLabel)
            make.width.height.equalTo(20)
        }
        
        cardView.addSubview(shareButton)
        shareButton.snp.makeConstraints { make in
            make.right.equalTo(actionsButton.snp.left)
                .offset(-16)
            make.width.height.centerY.equalTo(actionsButton)
        }
        
    }
    
    func updateCellBy(_ note: Note, _ row: Int) {
        collectButton.isSelected = note.favourite
        
        if let catelogue = note.category {
            tagLabel.text = " \(catelogue) "
        } else {
            tagLabel.text = " \(Localized("defaultCatelogue")) "
        }
        
        if let date = (AppSettings.shared.stickerDateUse == 0 ?
            note.createdAt : note.modificationDate) {
            updateLabel.text = date.toRelative()
        } else {
            updateLabel.text = nil
        }
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 0
        style.lineBreakMode = .byTruncatingMiddle
        style.maximumLineHeight = 20
        style.minimumLineHeight = 20
        
        let attrNote = NSAttributedString(string: note.content,
                                          attributes: [.font : UIFont.systemFont(ofSize: 14, weight: .semibold),
                                                       .paragraphStyle: style
                                                      ])
        contentLabel.attributedText = attrNote
        actionsButton.tag = row
    }
    
}
