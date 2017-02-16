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
    
    case filterAll
    case filterStar
    case filterUnstar
    case filterColor

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
            
//        case .filterAll:
//            return
            
        default:
            return ""
        }
    }
    
    func detailTypes() -> ([[SettingType]], [String]) {
        switch self {
        case .general:
            return ([[.date, .gesture], [.line, .line, .line, .line, .line]],
                    [Localized("sticker"), Localized("lines")])
            
        case .search:
            return ([[.caseSensitive], [.advance]], ["", ""])
        
        case .filter:
            return ([[.filterAll, .filterStar, .filterUnstar], [.filterColor, .filterColor, .filterColor, .filterColor, .filterColor, .filterColor]], ["", ""])
            
        default:
            fatalError("have not this type \(self)")
        }
    }
    
    func detailSettingConfig(cell: SettingsTableViewCell, row: Int) {
        
        cell.settingDetailLabel.isHidden = true
        cell.checkButton.isHidden = true
        cell.settingSwitch.isHidden = true
        let settings = AppSettings.shared
        switch self {
        case .date:
            cell.settingLabel.text = self.settingName()
            cell.settingDetailLabel.isHidden = false
            cell.settingDetailLabel.text = settings.stickerDateUse == 0 ? Localized("creationDate") : Localized("modificationDate")
            cell.accessoryType = .disclosureIndicator
            
        case .line:
            cell.settingLabel.text = "\(row + 4)"
            cell.checkButton.isHidden = settings.stickerLines != row
            cell.accessoryType = .none
            
        case .gesture:
            cell.settingLabel.text = Localized("stickerGusture")
            cell.settingDetailLabel.isHidden = false
            cell.settingDetailLabel.text = settings.stickerGesture == 0 ? Localized("gusture") : Localized("longGusture")
            cell.accessoryType = .disclosureIndicator
            
        case .caseSensitive:
            cell.settingLabel.text = Localized("caseSensitive")
            cell.settingSwitch.isHidden = false
            cell.settingSwitch.isOn = settings.caseSensitive == 0
            cell.accessoryType = .none
            
        case .advance:
            cell.settingLabel.text = Localized("advance")
            cell.accessoryType = .none
            
        default:
            fatalError("cant config this type \(self) cell")
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
                guard let _ = vc as? UIViewController else {
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
    var stickerDateUse: Int {
        didSet {
            UserDefaultsKey.dateLabelUse.write(value: self.stickerDateUse, manager: self.userDefualtsManager)
        }
    }
    // 4 5 6 7 8
    var stickerLines: Int {
        didSet {
            UserDefaultsKey.dateLabelUse.write(value: self.stickerLines, manager: self.userDefualtsManager)
        }
    }
    var keyboardLines: Int {
        didSet {
            UserDefaultsKey.dateLabelUse.write(value: self.keyboardLines, manager: self.userDefualtsManager)
        }
    }
    // 0 swipe 1 long press
    var stickerGesture: Int {
        didSet {
            UserDefaultsKey.dateLabelUse.write(value: self.stickerGesture, manager: self.userDefualtsManager)
        }
    }
    // 0 sensitive 1 none
    var caseSensitive: Int {
        didSet {
            UserDefaultsKey.dateLabelUse.write(value: self.caseSensitive, manager: self.userDefualtsManager)
        }
    }
    // 0 1 2 all star Unstar | 0 1 2 3 4 5 colors
    var keyboardFilterStar: Int {
        didSet {
            UserDefaultsKey.dateLabelUse.write(value: self.keyboardFilterStar, manager: self.userDefualtsManager)
        }
    }
    var keyboardFilterColor: Int {
        didSet {
            UserDefaultsKey.dateLabelUse.write(value: self.keyboardFilterColor, manager: self.userDefualtsManager)
        }
    }
    // 0 create 1 modify
    var stickerSort: Int {
        didSet {
            UserDefaultsKey.dateLabelUse.write(value: self.stickerSort, manager: self.userDefualtsManager)
        }
    }

    fileprivate let userDefualtsManager: UserDefaultsManager
    
    private init() {
        guard let userDefault = UserDefaultsManager(identifier: GroupIdentifier) else { fatalError("user defaults setup failed") }
        self.stickerDateUse = userDefault.readInt(UserDefaultsKey.dateLabelUse.rawValue)
        self.stickerLines = userDefault.readInt(UserDefaultsKey.stickerLine.rawValue)
        self.keyboardLines = userDefault.readInt(UserDefaultsKey.stickerLine.rawValue)
        self.keyboardFilterStar = userDefault.readInt(UserDefaultsKey.keyboardFilterStar.rawValue)
        self.keyboardFilterColor = userDefault.readInt(UserDefaultsKey.keyboardFilterColor.rawValue)
        self.stickerGesture = userDefault.readInt(UserDefaultsKey.gesture.rawValue)
        self.caseSensitive = userDefault.readInt(UserDefaultsKey.caseSensitive.rawValue)
        self.stickerSort = userDefault.readInt(UserDefaultsKey.stickerSort.rawValue)
        self.userDefualtsManager = userDefault
    }

    static let shared: AppSettings = AppSettings()

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
    
    func write(value: Int, manager: UserDefaultsManager) {
        manager.write(self.rawValue, value: value)
    }
}
