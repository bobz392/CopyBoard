//
//  AppSettings.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/17.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation

protocol AppSettingsNotify {
    func settingDidChange(settingKey: UserDefaultsKey)
}

class AppSettings {
    
    fileprivate var notifyObjects = [String: AppSettingsNotify]()
    
    // 0 create 1 modify
    var stickerDateUse: Int {
        didSet {
            UserDefaultsKey.dateLabelUse.write(value: self.stickerDateUse, manager: self.userDefualtsManager)
            self.didChange(key: UserDefaultsKey.dateLabelUse)
        }
    }
    // 0 1 2 3 4  -> 4 5 6 7 8
    var stickerLines: Int {
        didSet {
            UserDefaultsKey.stickerLine.write(value: self.stickerLines, manager: self.userDefualtsManager)
            self.didChange(key: UserDefaultsKey.stickerLine)
        }
    }
    var keyboardLines: Int {
        didSet {
            UserDefaultsKey.keyboardLine.write(value: self.keyboardLines, manager: self.userDefualtsManager)
            self.didChange(key: UserDefaultsKey.keyboardLine)
        }
    }
    // 0 swipe 1 long press
    var stickerGesture: Int {
        didSet {
            UserDefaultsKey.gesture.write(value: self.stickerGesture, manager: self.userDefualtsManager)
            self.didChange(key: UserDefaultsKey.gesture)
        }
    }
    // 0 sensitive 1 none
    var caseSensitive: Int {
        didSet {
            UserDefaultsKey.caseSensitive.write(value: self.caseSensitive, manager: self.userDefualtsManager)
            self.didChange(key: UserDefaultsKey.caseSensitive)
        }
    }
    // 0 1 2 all star Unstar | 0 1 2 3 4 5 colors
    var keyboardFilterStar: Int {
        didSet {
            UserDefaultsKey.keyboardFilterStar.write(value: self.keyboardFilterStar, manager: self.userDefualtsManager)
            self.didChange(key: UserDefaultsKey.keyboardFilterStar)
        }
    }
    var keyboardFilterColor: [Int] {
        didSet {
            UserDefaultsKey.keyboardFilterColor.write(value: self.keyboardFilterColor, manager: self.userDefualtsManager)
            self.didChange(key: UserDefaultsKey.keyboardFilterColor)
        }
    }
    // 0 create 1 modify
    var stickerSort: Int {
        didSet {
            UserDefaultsKey.stickerSort.write(value: self.stickerSort, manager: self.userDefualtsManager)
            self.didChange(key: UserDefaultsKey.stickerSort)
        }
    }
    
    var keyboardHeight: Int {
        didSet {
            UserDefaultsKey.keyboardHeight.write(value: self.keyboardHeight, manager: self.userDefualtsManager)
            self.didChange(key: UserDefaultsKey.keyboardHeight)
        }
    }
    
    var version: String
    
    fileprivate let userDefualtsManager: UserDefaultsManager
    
    private init() {
        guard let userDefault = UserDefaultsManager(identifier: GroupIdentifier) else { fatalError("user defaults setup failed") }
        self.stickerDateUse = userDefault.readInt(UserDefaultsKey.dateLabelUse.rawValue)
        self.stickerLines = userDefault.readInt(UserDefaultsKey.stickerLine.rawValue)
        self.keyboardLines = userDefault.readInt(UserDefaultsKey.stickerLine.rawValue)
        self.keyboardFilterStar = userDefault.readInt(UserDefaultsKey.keyboardFilterStar.rawValue)
        self.keyboardFilterColor = (userDefault.readArray(UserDefaultsKey.keyboardFilterColor.rawValue) as? [Int]) ?? [0]
        self.stickerGesture = userDefault.readInt(UserDefaultsKey.gesture.rawValue)
        self.caseSensitive = userDefault.readInt(UserDefaultsKey.caseSensitive.rawValue)
        self.stickerSort = userDefault.readInt(UserDefaultsKey.stickerSort.rawValue)
        self.keyboardHeight = userDefault.readInt(UserDefaultsKey.keyboardHeight.rawValue)
        
        if let v = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String,
            let b = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.version = "\(b)(\(v))"
        } else {
            self.version = ""
        }
        
        self.userDefualtsManager = userDefault
    }
    
    static let shared: AppSettings = AppSettings()
    
    func sortKey() -> String {
        return self.stickerSort == 0 ? "createdAt" : "modificationDate"
    }
    
    func caseSensitiveQuery(key: String, value: String) -> String {
        return "\(key) CONTAINS\(self.caseSensitive == 0 ? "" : "[c]") '\(value)'"
    }
    
    func register(any: AppSettingsNotify, key: String) {
        if let _ = self.notifyObjects[key] {
            fatalError("key - \(key) was arleady exists")
        }
        
        self.notifyObjects[key] = any
    }
    
    func unregister(key: String) {
        self.notifyObjects.removeValue(forKey: key)
    }
    
    fileprivate func didChange(key: UserDefaultsKey) {
        for n in self.notifyObjects {
            n.value.settingDidChange(settingKey: key)
        }
    }
    
}

enum UserDefaultsKey: StringLiteralType {
    case dateLabelUse = "com.date.label.use"
    case stickerLine = "com.sticker.line"
    case keyboardLine = "com.keyboard.line"
    case keyboardHeight = "com.keyboard.height"
    case gesture = "com.gesture"
    case caseSensitive = "com.case.sensitive"
    case keyboardFilterStar = "com.keyboard.filter.star"
    case keyboardFilterColor = "com.keyboard.filter.color"
    case stickerSort = "com.sticker.sort"
    
    func write<T>(value: T, manager: UserDefaultsManager) {
        manager.write(self.rawValue, value: value)
    }
    
}
