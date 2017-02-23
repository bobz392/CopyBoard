//
//  RealmManager.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/17.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

final class DBManager {
    static let version: UInt64 = 0
    typealias DBBlock = () -> Void
    
    static var shared = DBManager()
    weak var dataSource: RealmNotificationDataSource?
    var notesToken: RealmSwift.NotificationToken? = nil
    
    var realm: Realm?
    
    fileprivate var r: Realm {
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
        DBManager.shared.realm = try? Realm()
        Logger.log(DBManager.shared.realm?.configuration.fileURL?.absoluteString ?? "db file url = nil")
    }
    
    static private func containerDBURL() -> URL {
        let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: GroupIdentifier)!
        return directory.appendingPathComponent("db.realm")
    }
    
    static func checkKeyboardAccess() -> Bool {
        let r = try? Realm()
        
        return r != nil
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

// MARK: - notes
extension DBManager {
    
    func unbindNotify() {
        self.notesToken?.stop()
        self.dataSource = nil
    }
    
    func bindNotifyToken<T>(result: Results<T>, dataSource: RealmNotificationDataSource) {
        self.dataSource = dataSource
        self.notesToken = result.addNotificationBlock { (changes: RealmCollectionChange) in
            switch changes {
            case .initial(_):
                dataSource.dataInit()
                
            case .update(_, let deletions, let insertions, let modifications):
                dataSource.update(deletions: deletions, insertions: insertions, modifications: modifications)
                
            case .error(let error):
                Logger.log("realmNoticationToken error = \(error)")
            }
        }
        
    }
    
    func queryNotes(contain: String? = nil) -> Results<Note> {
        let sortKey = AppSettings.shared.sortKey()
        let ascending = AppSettings.shared.sortNewestLast
        if let contain = contain {
            let query = AppSettings.shared.caseSensitiveQuery(key: "content", value: contain)
            return self.r.objects(Note.self)
                .filter(query)
                .sorted(byKeyPath: sortKey, ascending: ascending)
        } else {
            return self.r.objects(Note.self)
                .sorted(byKeyPath: sortKey, ascending: ascending)
        }
    }
    
    func keyboardQueryNotes() -> Results<Note> {
        let settings = AppSettings.shared
        let sortKey = settings.sortKey()
        var all = self.r.objects(Note.self)
        if settings.keyboardFilterStar != 0 {
            all = all.filter("favourite = \(settings.keyboardFilterStar == 1 ? true : false)")
        }
        
        let cs = settings.keyboardFilterColor
        var qc = ""
        for (index, c) in cs.enumerated() {
            qc += "color = \(c)"
            
            if index != cs.count - 1 {
                qc += " OR "
            }
        }
        
        return all.filter(qc).sorted(byKeyPath: sortKey, ascending: false)
    }

    func deleteNote(note: Note) {
        self.deleteObject(note)
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
