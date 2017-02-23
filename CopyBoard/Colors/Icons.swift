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
        }
    }
    
    func iconImage() -> UIImage? {
        return UIImage(named: self.iconString())?.withRenderingMode(.alwaysTemplate)
    }
}
