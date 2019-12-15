//
//  Icons.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/18.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation

import UIKit

enum Icons {
    case search
    case setting
    case star
    case delete
    case clear
    case color
    case hideKeyboard
    case bigClear
    case info
    case done
    case back
    case globle
    case launch
    case deleteText
    case returnKey
    case preview
    case space
    case save
    case create
    case sync
    case number
    case text
    case filter
    case createManual
    
    func iconString() -> String {
        switch self {
        case .setting: return "setting"
        case .search:  return "search"
        case .star: return "star"
        case .delete: return "delete"
        case .clear:  return "clear"
        case .color: return "color"
        case .hideKeyboard: return "hideKeyboard"
        case .bigClear: return "big_clear"
        case .info: return "info"
        case .done: return "done"
        case .back: return "back"
        case .globle: return "globle"
        case .launch: return "launch"
        case .deleteText: return "deleteText"
        case .returnKey: return "return"
        case .preview: return "preview"
        case .space: return "space"
        case .save: return "save"
        case .create: return "create"
        case .sync: return "sync"
        case .number: return "number"
        case .text: return "text"
        case .filter: return "filter"
        case .createManual: return "createManual"
        }
    }
    
    func iconImage() -> UIImage? {
        return UIImage(named: self.iconString())?
            .withRenderingMode(.alwaysTemplate)
    }
    
    func configMainButton(button: UIButton) {
        button.setImage(self.iconImage(),
                        for: .normal)
        button.tintColor = AppColors.mainIcon
    }
}
