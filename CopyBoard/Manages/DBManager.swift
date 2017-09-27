//
//  RealmManager.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/17.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

final class DBManager {
    static let version: UInt64 = 2
    typealias DBBlock = () -> Void
    
    static var shared = DBManager()
    weak var dataSource: RealmNotificationDataSource?
    var notesToken: RealmSwift.NotificationToken? = nil
    
    var realm: Realm?
    
    internal var r: Realm {
        get {
            if let r = self.realm {
                return r
            } else {
                fatalError("realm not create")
            }
        }
    }
    
    static func configDB() {
        let realmURL = self.containerDBURL()
        
        debugPrint(realmURL)
        let config = Realm.Configuration(fileURL: realmURL,
                                         schemaVersion: version,
                                         migrationBlock: { (migration, oldSchemaVersion) in
                                            if (oldSchemaVersion < version) {}
        })
        Realm.Configuration.defaultConfiguration = config
        
        if let realm = try? Realm() {
            DBManager.shared.realm = realm
            Logger.log(DBManager.shared.realm?.configuration.fileURL?.absoluteString ?? "db file url = nil")
        }
    }
    
    static private func containerDBURL() -> URL {
        let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: GroupIdentifier)!
        return directory.appendingPathComponent("db.realm")
    }
    
    static func canFullAccess() -> Bool {
        let fm = FileManager.default
        do {
            var directory = fm.containerURL(forSecurityApplicationGroupIdentifier: GroupIdentifier)!
            directory.appendPathComponent("1.txt")
            try fm.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            try fm.removeItem(at: directory)
            return true
        } catch _ {
            return false
        }
    }
    
    func writeObject(_ object: Object) {
        try? r.write {
            r.add(object)
        }
    }
    
    func deleteObject(_ object: Object) {
        try? r.write {
            r.delete(object)
        }
    }
    
    func updateObject(_ notify: Bool = true, updateBlock: @escaping DBBlock) {
        r.beginWrite()
        updateBlock()
        var tokens = [NotificationToken]()
        if notify == false, let token = self.notesToken {
            tokens.append(token)
        }
        try? r.commitWrite(withoutNotifying: tokens)
    }
    
    func writeObjects( notify: Bool = true, objects: [Object]) {
        var tokens = [NotificationToken]()
        if notify == false, let token = self.notesToken {
            tokens.append(token)
        }
        
        r.beginWrite()
        r.add(objects)
        try? r.commitWrite(withoutNotifying: tokens)
    }
    
}

struct UUIDGenerator {
    static func getUUID() -> String {
        return NSUUID().uuidString
    }
}

//MARK: - 自动通知的协议
protocol RealmNotificationDataSource: NSObjectProtocol {
    func dataInit()
    func update(deletions: [Int], insertions: [Int], modifications: [Int])
}
