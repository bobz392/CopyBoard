//
//  SettingItem.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/13.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

enum SettingType {
    case general
    case search
    case keyboardLine
    case keyboardHeight
    case filter

    case date
    case line
    case gesture

    case caseSensitive
    case advance

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
    
    func detailTypes() -> ([[SettingType]], [String]) {
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

enum SettingSelectType {
    case push
    case value
    case select
    
    func action() -> ((Any) -> Void) {
        switch self {
        case .push:
            return { (vc) in
                guard let c = vc as? UIViewController else {
                    fatalError("push type must have UIViewController")
                }
                
                
            }
            
        case .value:
            return { (value) in
            }
        case .select:
            return { (value) in
            }
            
        }
    }
}

enum SettingDetailType {
    case date
    case line
    case gesture

    case caseSensitive
    case advance
    
//    func settingUI(nameLabel: UILabel, detailLabel: UILabel, switch: UISwitch, row: Int) -> Str {
//        switch self {
//        case .date:
//            nameLabel.text = Localized("stickerDate")
//            detailLable.text =
//            return .disclosureIndicator
//
//        case .line:
//            return ""
//        case .gesture:
//            return (Localized("stickerLine"), .disclosureIndicator)
//
//
//        case .caseSensitive:
//            return Localized("caseSensitive")
//        case .advance:
//            return Localized("filter")
//        }
//    }
    
    
    func detailSelectType() -> SettingSelectType {
        switch self {
        case .date:
            return .push
        case .line:
            return .select
        case .gesture:
            return .push

        case .caseSensitive:
            return .value
        case .advance:
            return .value
        }
    }
    
}

class AppSettings {

    // 0 create 1 modify
    var stickerDateUse: Int
    // 4 5 6 7 8
    var stickerLines: Int
    var keyboardLines: Int
    // 0 swipe 1 long press
    var stickerGesture: Int
    // 0 sensitive 1 none
    var caseSensitive: Int
    // 0 1 2 all star Unstar | 0 1 2 3 4 5 colors
    var keyboardFilterStar: Int
    var keyboardFilterColor: Int
    // 0 create 1 modify
    var stickerSort: Int

    private init() {
        guard let userDefault = UserDefaultsManager(identifier: GroupIdentifier) else { fatalError("user defaults setup failed") }
        self.stickerDateUse = userDefault.readInt(UserDefaultsKey.dateLabelUse.rawValue)
        self.stickerLines = userDefault.readInt(UserDefaultsKey.stickerLine.rawValue) + 4
        self.keyboardLines = userDefault.readInt(UserDefaultsKey.stickerLine.rawValue) + 4
        self.keyboardFilterStar = userDefault.readInt(UserDefaultsKey.keyboardFilterStar.rawValue)
        self.keyboardFilterColor = userDefault.readInt(UserDefaultsKey.keyboardFilterColor.rawValue)
        self.stickerGesture = userDefault.readInt(UserDefaultsKey.gesture.rawValue)
        self.caseSensitive = userDefault.readInt(UserDefaultsKey.caseSensitive.rawValue)
        self.stickerSort = userDefault.readInt(UserDefaultsKey.stickerSort.rawValue)
    }

    let shard: AppSettings = AppSettings()

}

enum UserDefaultsKey: StringLiteralType {
    case dateLabelUse = "com.date.label.use"
    case stickerLine = "com.sticker.line"
    case keyboardLine = "com.keyboard.line"
    case gesture = "com.gesture"
    case caseSensitive = "com.case.sensitive"
    case keyboardFilterStar = "com.keyboard.filter.star"
    case keyboardFilterColor = "com.keyboard.filter.color"
    case stickerSort = "com.sticker.sort"
}