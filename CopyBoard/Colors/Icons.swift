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
    
    
    case plus
    case check
    case uncheck
    case coffee
    case timeManagement
    
    case loop
    case notify
    case schedule
    case smallPlus
    case tag
    case due
    case note
    case smallDelete
    case arrangement
    case calendar
    case readLater
    
    case weekStart
    case home
    case finish
    case unfinish
    case export
    case closeDown
    case save
    case rename
    case briefcase
    case about
    case delay
    case sound
    case mail
    case play
    case stop
    
    
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
            
            
        case .plus: return "plus"
        case .check: return "check"
        case .uncheck: return "uncheck"
        case .coffee: return "coffee"
    
        case .timeManagement: return "time_management"
        
        
        case .loop: return "loop"
        case .notify: return "notify"
        case .schedule: return "schedule"
        case .smallPlus: return "small_plus"
        case .tag: return "tag"
        case .due: return "due"
        case .note: return "note"
        case .smallDelete: return "small_delete"
        case .arrangement: return "arrangement"
        case .calendar: return "calendar"
        
        case .home: return "home"
        case .finish: return "finish"
        case .unfinish: return "unfinish"
        case .export: return "export"
        case .closeDown: return "close_down"
        case .save: return "save"
        case .rename: return "rename"
        case .briefcase: return "briefcase"
        case .about: return "about"
        case .delay: return "delay"
        case .mail: return "mail"
        case .sound: return "sound"
        case .weekStart: return "week_start"
        case .readLater: return "read_later"
        case .play: return "play"
        case .stop: return "stop"
        }
    }
    
    func iconImage() -> UIImage? {
        return UIImage(named: self.iconString())?.withRenderingMode(.alwaysTemplate)
    }
}
