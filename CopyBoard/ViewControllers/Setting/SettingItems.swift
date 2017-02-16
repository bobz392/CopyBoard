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
    case filter
    
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
        case .filter:
            return Localized("filter")
        }
    }
    
    func detailTypes() -> ([[SettingDetialType]], [String]) {
        switch self {
        case .general:
            return ([[.date, .gesture], [.line, .line, .line, .line, .line]],
                    [Localized("sticker"), Localized("lines")])
            
        case .search:
            return ([[.caseSensitive], [.advance]], ["", ""])
            
        default:
            fatalError("have not this type \(self)")
        }
    }
    
    
}

struct SettingItemCreator {
    
    func settingsCreator() -> [[SettingType]] {
        let section1: [SettingType] = [.general, .search]
        let section2: [SettingType] = [.keyboardHeight, .keyboardLine, .filter]
        let section3: [SettingType] = [.general, .general, .general, .general, .general]
        
        return [section1, section2, section3]
    }
    
    func settingsHeader() -> [String] {
        return ["", Localized("keyboard"), Localized("extra")]
    }
    
}

enum SettingDetialType {
    case date
    case line
    case gesture
    
    case caseSensitive
    case advance
    
    func settingName() -> String {
        switch self {
        case .date:
            return Localized("stickerDate")
        case .line:
            return ""
        case .gesture:
            return Localized("stickerLine")
  
            
        case .caseSensitive:
            return Localized("caseSensitive")
        case .advance:
            return Localized("filter")
        }
    }
    
    
}
