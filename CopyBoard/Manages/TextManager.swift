//
//  TextManager.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/24.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation

func Localized(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

func appFont(size: CGFloat, weight: CGFloat = UIFontWeightRegular) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: weight)
}

func emptyNotesFont() -> CGFloat {
    let dm = DeviceManager.shared
    
    if dm.isPhone() {
        switch dm.phoneScreenType() {
        case .phone5:
            return 18
        case .phone6:
            return 20
        case .phone6p:
            return 24
        }
    } else {
        return 0
    }
}
