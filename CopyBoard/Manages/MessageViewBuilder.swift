//
//  MessageView.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/10/11.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation
import SwiftMessages

extension String {
    func saveToUserDefault(value: Bool) {
        UserDefaults.standard.set(value, forKey: self)
        UserDefaults.standard.synchronize()
    }
    
    func valueForKeyInUserDefault() -> Bool {
        return UserDefaults.standard.bool(forKey: self)
    }
}

struct MessageViewBuilder {
    static let kFirstNoteKey = "com.zhoubo.notes.view.controller"
    static let kFirstEditorKey = "com.zhoubo.editor.view.controller"
    
    static func showMessageView(title: String, body: String, checkKey: String) {
        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        config.duration = .forever
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureContent(title: title, body: body, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "OK", buttonTapHandler: { (button) in
            SwiftMessages.hide()
            checkKey.saveToUserDefault(value: true)
        })
        view.configureTheme(.info)
        view.iconLabel?.isHidden = true
        view.iconImageView?.isHidden = true
        view.backgroundView.backgroundColor = AppPairColors.sand.pairColor().light
        view.button?.backgroundColor = AppPairColors.sand.pairColor().light
        view.button?.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        view.button?.setTitleColor(AppColors.faveButton, for: .normal)
        view.configureDropShadow()
        SwiftMessages.show(config: config, view: view)
    }
    
    static func hiddenMessageView() {
        SwiftMessages.hide()
    }
}
