//
//  MessageView.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/10/11.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation
import TTGSnackbar

let kFirstUseNoteKey = "com.zhoubo.notes.view.controller"
let kFirstUseEditorKey = "com.zhoubo.editor.view.controller"


extension String {
    func saveToUserDefault(value: Bool) {
        UserDefaults.standard.set(value, forKey: self)
        UserDefaults.standard.synchronize()
    }
    
    func valueForKeyIsInUserDefault() -> Bool {
        return UserDefaults.standard.bool(forKey: self)
    }
}

struct MessageViewBuilder {
    static func showMessageViewIfFirstUse(checkKey: String) {
        guard !checkKey.valueForKeyIsInUserDefault()
            else { return }
        let message: String
        if checkKey == kFirstUseNoteKey {
            message = "\(Localized("message1")) \(Localized("message2"))"
        } else {
            message = "\(Localized("message1")) \(Localized("message3"))"
        }
        
        let snackbar = TTGSnackbar(
            message: message,
            duration: .forever,
            actionText: Localized("got"),
            actionBlock: { (snackbar) in
                snackbar.dismiss()
            }
        )
        checkKey.saveToUserDefault(value: true)
        snackbar.show()
    }
}
