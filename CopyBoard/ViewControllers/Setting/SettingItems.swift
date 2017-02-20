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

    case dateLabel
    case line
    
    case gesture
    case swipe
    case longPress

    case caseSensitive
    case advance
    
    case filterAll
    case filterStar
    case filterUnstar
    case filterColor
    
    case sortBy
    
    case rate
    case contact

    case creationDate
    case modifyDate
    
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

        case .dateLabel:
            return Localized("stickerDate")
        case .gesture:
            return Localized("stickerGusture")

        case .swipe:
            return Localized("swipe")
        case .longPress:
            return Localized("longGusture")

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

        case .contact:
            return Localized("contactUs")
        case .rate:
            return Localized("rate")
            
        case .sortBy:
            return Localized("sortBy")
        
        case .modifyDate:
            return Localized("modificationDate")
        case .creationDate:
            return Localized("creationDate")
            
        default:
            return ""
        }
    }
    
    func selectedType() -> SettingSelectType {
        switch self {
        case .dateLabel:
            return .push
        case .line:
            return .select
        case .gesture:
            return .push
        case .sortBy:
            return .push
        
        case .modifyDate, .creationDate:
            return .select
        
        case .longPress, .swipe:
            return .select
            
        case .filterAll, .filterColor, .filterStar, .filterUnstar:
            return .select
            
        case .caseSensitive:
            return .value
 
        default:
            fatalError("this type cant select, \(self)")
        }
    }
 
    // types and header titles
    func detailTypes() -> ([[SettingType]], [String]) {
        switch self {
        case .general:
            return ([[.dateLabel, .gesture], [.sortBy], [.line, .line, .line, .line, .line]],
                    [Localized("sticker"), Localized("sort"), Localized("stickerLines")])
            
        case .search:
            return ([[.caseSensitive], [.advance]], ["", Localized("advance")])
            
        case .filter:
            return ([[.filterAll, .filterStar, .filterUnstar],
                     [.filterColor, .filterColor, .filterColor, .filterColor, .filterColor, .filterColor]],
                    [Localized("star"), Localized("color")])
            
        case .keyboardHeight:
            return ([[.keyboardHeight]], [""])
            
        case .keyboardLine:
            return ([[.line, .line, .line, .line, .line]], [""])
            
        case .dateLabel, .sortBy:
            return ([[.creationDate, .modifyDate]], [""])
            
        case .gesture:
            return ([[.swipe, .longPress]], [""])
            
        default:
            fatalError("have not this type \(self)")
        }
    }
    
    func detailSettingConfig(cell: SettingsTableViewCell, rootSettingType: SettingType, row: Int, section: Int) {
        
        cell.settingDetailLabel.isHidden = true
        cell.checkButton.isHidden = true
        cell.settingSwitch.isHidden = true
        cell.resetFilterColorView()
        cell.settingLabel.text = self.settingName()
        cell.switchBlock = nil
        
        let settings = AppSettings.shared
        
        switch self {
        case .dateLabel:
            cell.settingDetailLabel.isHidden = false
            cell.settingDetailLabel.text = settings.stickerDateUse == 0 ? Localized("creationDate") : Localized("modificationDate")
            cell.accessoryType = .disclosureIndicator
            
        case .line, .keyboardLine:
            cell.settingLabel.text = "\(settings.realKeyboardLine(line: row)) \(Localized("lines"))"
            if section != 0 {
                cell.checkButton.isHidden = settings.stickerLines != row
            } else {
                cell.checkButton.isHidden = settings.keyboardLines != row
            }
            cell.accessoryType = .none
            
        case .gesture:
            cell.settingDetailLabel.isHidden = false
            cell.settingDetailLabel.text = settings.stickerGesture == 0 ? Localized("swipe") : Localized("longGusture")
            cell.accessoryType = .disclosureIndicator
          
        case .sortBy:
            cell.settingDetailLabel.isHidden = false
            cell.settingDetailLabel.text = settings.stickerSort == 0 ? Localized("creationDate") : Localized("modificationDate")
            cell.accessoryType = .disclosureIndicator
            
        case .caseSensitive:
            cell.settingSwitch.isHidden = false
            cell.settingSwitch.isOn = settings.caseSensitive == 0
            cell.switchBlock = { () -> SettingType in
                return self
            }
            cell.accessoryType = .none
            
        case .advance:
            cell.accessoryType = .none
            
        case .filterUnstar, .filterStar, .filterAll, .filterColor:
            if self == .filterColor {
                if let pairColor = AppPairColors(rawValue: row) {
                    cell.filterColorView?.isHidden = false
                    cell.filterColorView?.backgroundColor = pairColor.pairColor().dark
                }
            }
            cell.accessoryType = .none
            if section == 0 {
                cell.checkButton.isHidden = settings.keyboardFilterStar != row
            } else {
                cell.checkButton.isHidden = !settings.keyboardFilterColor.contains(row)
            }
            
        case .creationDate, .modifyDate:
            if rootSettingType == .sortBy {
                cell.checkButton.isHidden = settings.stickerSort != row
            } else {
                cell.checkButton.isHidden = settings.stickerDateUse != row
            }
            cell.accessoryType = .none
            
        case .swipe, .longPress:
            cell.checkButton.isHidden = settings.stickerGesture != row
            cell.accessoryType = .none
            
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
        let section2: [SettingType] = [/**.keyboardHeight, **/.keyboardLine, .filter]
        let section3: [SettingType] = [.contact, .rate]
        
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
    
    func selectAction(rootSettingType: SettingType, selectedType: SettingType, row: Int, section: Int) {
        let settings = AppSettings.shared
        switch rootSettingType {
        case .dateLabel:
            settings.stickerDateUse = selectedType == .creationDate ? 0 : 1
            
        case .sortBy:
            settings.stickerSort = selectedType == .creationDate ? 0 : 1
            
        case .gesture:
            settings.stickerGesture = selectedType == .swipe ? 0 : 1
        
        case .general:
            if selectedType == .line {
                settings.stickerLines = row
            }
        
        case .keyboardLine:
            settings.keyboardLines = row
            
        case .filter:
            if section == 0 {
                settings.keyboardFilterStar = row
            } else {
                if let index = settings.keyboardFilterColor.index(of: row) {
                    settings.keyboardFilterColor.remove(at: index)
                } else {
                    settings.keyboardFilterColor.append(row)
                }
            }
            
        default:
            fatalError("\(selectedType) havn't this action")
        }
    }
    
    func valueAction(isOn: Bool, selectedType: SettingType) {
        if selectedType == .caseSensitive {
            AppSettings.shared.caseSensitive = isOn ? 0 : 1
        }
    }
}
