//
//  AppSettings.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/17.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation

let kFilterNoneType = "无"

protocol AppSettingsNotify {
    func settingDidChange(settingKey: UserDefaultsKey)
}

class AppSettings {
    
    fileprivate var notifyObjects = [String: AppSettingsNotify]()
    
    // 0 create 1 modify
    var stickerDateUse: Int {
        didSet {
            UserDefaultsKey.dateLabelUse
                .write(value: stickerDateUse,
                       manager: userDefualtsManager)
            didChange(key: UserDefaultsKey.dateLabelUse)
        }
    }
    // 0 1 2 3 4  -> 4 5 6 7 8
    var stickerLines: Int {
        didSet {
            UserDefaultsKey.stickerLine
                .write(value: stickerLines,
                       manager: userDefualtsManager)
            didChange(key: UserDefaultsKey.stickerLine)
        }
    }
    var keyboardLines: Int {
        didSet {
            UserDefaultsKey.keyboardLine
                .write(value: keyboardLines,
                       manager: userDefualtsManager)
            didChange(key: UserDefaultsKey.keyboardLine)
        }
    }
    // 0 swipe 1 long press
    var stickerGesture: Int {
        didSet {
            UserDefaultsKey.gesture
                .write(value: stickerGesture,
                       manager: userDefualtsManager)
            didChange(key: UserDefaultsKey.gesture)
        }
    }
    // 0 sensitive 1 none
    var caseSensitive: Int {
        didSet {
            UserDefaultsKey.caseSensitive
                .write(value: caseSensitive,
                       manager: userDefualtsManager)
            didChange(key: UserDefaultsKey.caseSensitive)
        }
    }
    // 0 1 2 all star Unstar | 0 1 2 3 4 5 colors
    var keyboardFilterStar: Int {
        didSet {
            UserDefaultsKey.keyboardFilterStar
                .write(value: keyboardFilterStar,
                       manager: userDefualtsManager)
            didChange(key: UserDefaultsKey.keyboardFilterStar)
        }
    }
    var keyboardFilterColor: [Int] {
        didSet {
            UserDefaultsKey.keyboardFilterColor
                .write(value: keyboardFilterColor,
                       manager: userDefualtsManager)
            didChange(key: UserDefaultsKey.keyboardFilterColor)
        }
    }
    // 0 create 1 modify
    var stickerSort: Int {
        didSet {
            UserDefaultsKey.stickerSort
                .write(value: stickerSort,
                       manager: userDefualtsManager)
            didChange(key: UserDefaultsKey.stickerSort)
        }
    }
    
    var keyboardHeight: Int {
        didSet {
            UserDefaultsKey.keyboardHeight
                .write(value: keyboardHeight,
                       manager: userDefualtsManager)
            didChange(key: UserDefaultsKey.keyboardHeight)
        }
    }
    
    // 0 = true | 1 = false
    var sortNewestLast: Bool {
        didSet {
            UserDefaultsKey.keyboardHeight
                .write(value: sortNewestLast,
                       manager: userDefualtsManager)
            didChange(key: UserDefaultsKey.stickerSortNewestLast)
        }
    }
    
    var appSetup: Bool {
        didSet {
            UserDefaultsKey.appSetup
                .write(value: appSetup,
                       manager: userDefualtsManager)
            didChange(key: UserDefaultsKey.appSetup)
        }
    }
    
    var lastSync: Date {
        didSet {
            let s = DateFormatter
                .localizedString(from: lastSync,
                                 dateStyle: .full,
                                 timeStyle: .full)
            UserDefaultsKey.lastSync
                .write(value: s,
                       manager: userDefualtsManager)
            didChange(key: UserDefaultsKey.lastSync)
        }
    }
    
    var keyboardDefaultNote: [String] {
        didSet {
            UserDefaultsKey.keyboardDefaultNote
                .write(value: keyboardDefaultNote,
                       manager: userDefualtsManager)
            didChange(key: UserDefaultsKey.keyboardDefaultNote)
        }
    }
    
    var keyboardSegmentationOpen: Bool {
        didSet {
            UserDefaultsKey.keyboardSegmentation
                .write(value: keyboardSegmentationOpen,
                       manager: userDefualtsManager)
            didChange(key: UserDefaultsKey.keyboardSegmentation)
        }
    }
    
    var hideCreateButton: Bool {
        didSet {
            UserDefaultsKey.hideCreateButton
                .write(value: hideCreateButton,
                       manager: userDefualtsManager)
            didChange(key: UserDefaultsKey.hideCreateButton)
        }
    }
    
    var filterColorNote: String {
        didSet {
            UserDefaultsKey.filterColorNote
                .write(value: filterColorNote,
                       manager: userDefualtsManager)
            didChange(key: UserDefaultsKey.filterColorNote)
        }
    }
    
    var filterColorType: Int? {
        get {
            if filterColorNote == kFilterNoneType {
                return nil
            } else {
                return Int(filterColorNote)
            }
        }
    }
    
    var version: String
    
    fileprivate let userDefualtsManager: UserDefaultsManager
    
    private init() {
        guard let userDefault = UserDefaultsManager(identifier: GroupIdentifier) else { fatalError("user defaults setup failed") }
        self.stickerDateUse = userDefault.readInt(UserDefaultsKey.dateLabelUse.rawValue)
        self.stickerLines = userDefault.readInt(UserDefaultsKey.stickerLine.rawValue)
        self.keyboardLines = userDefault.readInt(UserDefaultsKey.keyboardLine.rawValue)
        self.keyboardFilterStar = userDefault.readInt(UserDefaultsKey.keyboardFilterStar.rawValue)
        self.keyboardFilterColor = (userDefault.readArray(UserDefaultsKey.keyboardFilterColor.rawValue) as? [Int]) ?? [0, 1, 2, 3, 4, 5]
        self.stickerGesture =
            userDefault.readInt(UserDefaultsKey.gesture.rawValue)
        self.caseSensitive = userDefault.readInt(UserDefaultsKey.caseSensitive.rawValue)
        self.stickerSort = userDefault.readInt(UserDefaultsKey.stickerSort.rawValue)
        self.keyboardHeight = userDefault.readInt(UserDefaultsKey.keyboardHeight.rawValue)
        self.sortNewestLast = userDefault.readBool(UserDefaultsKey.stickerSortNewestLast.rawValue)
        self.keyboardDefaultNote = (userDefault.readArray(UserDefaultsKey.keyboardDefaultNote.rawValue) as? [String]) ?? Note.createDefaultNote()

        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        let lastSyncDate = formatter.date(from: userDefault.readString(UserDefaultsKey.lastSync.rawValue) ?? "")
            ?? Date()
        self.lastSync = lastSyncDate
        self.appSetup = userDefault.readBool(UserDefaultsKey.appSetup.rawValue)
        self.keyboardSegmentationOpen = userDefault.readBool(UserDefaultsKey.keyboardSegmentation.rawValue)
        self.hideCreateButton =
            userDefault.readBool(UserDefaultsKey.hideCreateButton.rawValue)
        self.filterColorNote =
            userDefault.readString(UserDefaultsKey.filterColorNote.rawValue)
            ?? kFilterNoneType
        if let v = Bundle.main
            .infoDictionary?[kCFBundleVersionKey as String] as? String,
            let b = Bundle.main
                .infoDictionary?["CFBundleShortVersionString"] as? String {
            version = "\(b) (\(v))"
        } else {
            version = ""
        }
        
        userDefualtsManager = userDefault
    }
    
    func reload() {
        stickerDateUse = userDefualtsManager.readInt(UserDefaultsKey.dateLabelUse.rawValue)
        stickerLines = userDefualtsManager.readInt(UserDefaultsKey.stickerLine.rawValue)
        keyboardLines = userDefualtsManager.readInt(UserDefaultsKey.keyboardLine.rawValue)
        keyboardFilterStar = userDefualtsManager.readInt(UserDefaultsKey.keyboardFilterStar.rawValue)
        keyboardFilterColor = (userDefualtsManager.readArray(UserDefaultsKey.keyboardFilterColor.rawValue) as? [Int]) ?? [0]
        stickerGesture = userDefualtsManager.readInt(UserDefaultsKey.gesture.rawValue)
        caseSensitive = userDefualtsManager.readInt(UserDefaultsKey.caseSensitive.rawValue)
        stickerSort = userDefualtsManager.readInt(UserDefaultsKey.stickerSort.rawValue)
        keyboardHeight = userDefualtsManager.readInt(UserDefaultsKey.keyboardHeight.rawValue)
        sortNewestLast = userDefualtsManager.readBool(UserDefaultsKey.stickerSortNewestLast.rawValue)
        keyboardSegmentationOpen = userDefualtsManager.readBool(UserDefaultsKey.keyboardSegmentation.rawValue)
        filterColorNote = userDefualtsManager.readString(UserDefaultsKey.filterColorNote.rawValue) ?? kFilterNoneType
    }
    
    static let shared: AppSettings = AppSettings()
    
    func sortKey() -> String {
        return stickerSort == 0 ? "createdAt" : "modificationDate"
    }
    
    func caseSensitiveQuery(key: String, value: String) -> String {
//        \(self.caseSensitive == 0 ? "" : "[c]")
        return "\(key) CONTAINS '\(value)'"
    }
    
    func register(any: AppSettingsNotify, key: String) {
        if let _ = notifyObjects[key] {
            fatalError("key - \(key) was arleady exists")
        }
        
        notifyObjects[key] = any
    }
    
    func unregister(key: String) {
        notifyObjects.removeValue(forKey: key)
    }
    
    fileprivate func didChange(key: UserDefaultsKey) {
        for n in notifyObjects {
            n.value.settingDidChange(settingKey: key)
        }
    }
    
    func realKeyboardLine(line: Int? = nil,
                          inKeyboardExtension: Bool = false) -> Int {
        return (line ?? keyboardLines) + (inKeyboardExtension ? 2 : 4)
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
    case stickerSortNewestLast = "com.sticker.newest.last"
    case appSetup = "com.app.setup"
    case lastSync = "com.last.sync"
    case keyboardDefaultNote = "com.keyboard.default"
    case keyboardSegmentation = "com.keyboard.segmentation"
    case hideCreateButton = "com.create.button.hide"
    case filterColorNote = "com.filter.color.note"
    
    func write<T>(value: T, manager: UserDefaultsManager) {
        manager.write(rawValue, value: value)
    }
    
}
