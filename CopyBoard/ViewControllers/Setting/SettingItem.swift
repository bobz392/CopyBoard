//
//  SettingItem.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/13.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation

enum SettingType {
    case general
    case search
    
    case keyboardLine
    case keyboardHeight
    
    func settingName() -> String {
        switch self {
        case .general:
            return Localized("general")
        case .search:
            return Localized("search")
            
        case .keyboardLine:
            return Localized("stickerLine")
        case .keyboardHeight:
            return Localized("keyboardHeight")
        }
    }
}

struct SettingItemCreator {
    
    func creator() -> [[SettingType]] {
        let section1: [SettingType] = [.general, .search]
        let section2: [SettingType] = [.keyboardHeight, .keyboardLine]
        let section3: [SettingType] = [.general]
        
        return [section1, section2, section3]
    }
    
}
