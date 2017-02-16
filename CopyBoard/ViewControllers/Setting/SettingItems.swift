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
    
    case sortBy
    
    case version
    case rate
    case contact

    func settingName() -> String {
        switch self {
        case .general:
            return Localized("general")
        case .search:
            return Localized("search")
        case .keyboardLine:
            return Localized("stickerLines")
        case .keyboardHeight:
            return Localized("keyboardHeight")
        case .filter:
            return Localized("filter")

        case .date:
            return Localized("stickerDate")
        case .line:
            return ""
        case .gesture:
            return Localized("stickerGusture")


        case .caseSensitive:
            return Localized("caseSensitive")
        case .advance:
            return Localized("advance")
            
        case .filterAll:
            return Localized("filterAll")
        case .filterStar:
            return Localized("filterStar")
        case .filterUnstar:
            return Localized("filterUnstar")
            
        case .version:
            return Localized("version")
        case .contact:
            return Localized("contactUs")
        case .rate:
            return Localized("rate")
            
        case .sortBy:
            return Localized("sortBy")
            
        default:
            return ""
        }
    }
    
    // types and header titles
    func detailTypes() -> ([[SettingType]], [String]) {
        switch self {
        case .general:
            return ([[.date, .gesture], [.sortBy], [.line, .line, .line, .line, .line]],
                    [Localized("sticker"), Localized("sort"), Localized("stickerLines")])
            
        case .search:
            return ([[.caseSensitive], [.advance]], ["", ""])
            
        case .filter:
            return ([[.filterAll, .filterStar, .filterUnstar],
                     [.filterColor, .filterColor, .filterColor, .filterColor, .filterColor, .filterColor]],
                    [Localized("star"), Localized("color")])
            
        case .keyboardHeight:
            return ([[.keyboardHeight]], [""])
            
        case .keyboardLine:
            return ([[.line, .line, .line, .line, .line]], [""])
            
        default:
            fatalError("have not this type \(self)")
        }
    }
    
    func detailSettingConfig(cell: SettingsTableViewCell, row: Int, section: Int) {
        
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
            
        case .line, .keyboardLine:
            cell.settingLabel.text = "\(row + 4) \(Localized("lines"))"
            if self == .line {
                cell.checkButton.isHidden = settings.stickerLines != row
            } else {
                cell.checkButton.isHidden = settings.keyboardLines != row
            }
            cell.accessoryType = .none
            
        case .gesture:
            cell.settingLabel.text = self.settingName()
            cell.settingDetailLabel.isHidden = false
            cell.settingDetailLabel.text = settings.stickerGesture == 0 ? Localized("gusture") : Localized("longGusture")
            cell.accessoryType = .disclosureIndicator
          
        case .sortBy:
            cell.settingLabel.text = self.settingName()
            cell.settingDetailLabel.isHidden = false
            cell.settingDetailLabel.text = settings.stickerSort == 0 ? Localized("creationDate") : Localized("modificationDate")
            cell.accessoryType = .disclosureIndicator
        
        case .caseSensitive:
            cell.settingLabel.text = self.settingName()
            cell.settingSwitch.isHidden = false
            cell.settingSwitch.isOn = settings.caseSensitive == 0
            cell.accessoryType = .none
            
        case .advance:
            cell.settingLabel.text = self.settingName()
            cell.accessoryType = .none
            
        case .filterUnstar, .filterStar, .filterAll, .filterColor:
            if self == .filterColor {
            } else {
                cell.settingLabel.text = self.settingName()
            }
            cell.accessoryType = .none
            if section == 0 {
                cell.checkButton.isHidden = settings.keyboardFilterStar != row
            } else {
                cell.checkButton.isHidden = settings.keyboardFilterColor != row
            }
            
        case .keyboardHeight:
            cell.settingLabel.text = Localized("keyboardHeight")
            cell.settingDetailLabel.text = "\(settings.keyboardHeight)pt"
            cell.accessoryType = .disclosureIndicator
            
        default:
            fatalError("cant config this type \(self) cell")
        }
    }
    
}

struct SettingItemCreator {
    
    func settingsCreator() -> [[SettingType]] {
        let section1: [SettingType] = [.general, .search]
        let section2: [SettingType] = [.keyboardHeight, .keyboardLine, .filter]
        let section3: [SettingType] = [.version, .contact, .rate]
        
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
