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
    
    static let shared = DBManager(realm: DBManager.beSuredCreate())
    weak var dataSource: RealmNotificationDataSource?
    var notesToken: RealmSwift.NotificationToken? = nil
    
    let realm: Realm
    
    init(realm: Realm) {
        self.realm = realm
    }
    
    static func configDB() {
        let realmURL = self.containerDBURL()
        
        let config = Realm.Configuration(fileURL: realmURL,
                            schemaVersion: version,
                            migrationBlock: { (migration, oldSchemaVersion) in
                                if (oldSchemaVersion < version) {}
        })
        Logger.log(DBManager.shared.realm.configuration.fileURL?.absoluteString ?? "db file url = nil")
        Realm.Configuration.defaultConfiguration = config
    }
    
    static private func beSuredCreate() -> Realm {
        return try! Realm()
    }
    
    static private func containerDBURL() -> URL {
        let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: GroupIdentifier)!
        return directory.appendingPathComponent("Library/Caches/db.realm")
    }
    
    static func checkKeyboardAccess() -> Bool {
        let r = try? Realm()
        
        return r != nil
    }
    
    func writeObject(_ object: Object) {
        try? realm.write {
            realm.add(object)
        }
    }
    
    func deleteObject(_ object: Object) {
        try? realm.write {
            realm.delete(object)
        }
    }
    
    func updateObject(_ notify: Bool = true, updateBlock: @escaping DBBlock) {
        realm.beginWrite()
        updateBlock()
        var tokens = [NotificationToken]()
        if notify == false, let token = self.notesToken {
            tokens.append(token)
        }
        try? realm.commitWrite(withoutNotifying: tokens)
    }
    
    func writeObjects( notify: Bool = true, objects: [Object]) {
        var tokens = [NotificationToken]()
        if notify == false, let token = self.notesToken {
            tokens.append(token)
        }

        realm.beginWrite()
        realm.add(objects)
        try? realm.commitWrite(withoutNotifying: tokens)
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
        if let contain = contain {
            let query = AppSettings.shared.caseSensitiveQuery(key: "content", value: contain)
            return self.realm.objects(Note.self)
                .filter(query)
                .sorted(byKeyPath: sortKey, ascending: false)
        } else {
            return self.realm.objects(Note.self)
                .sorted(byKeyPath: sortKey, ascending: false)
        }
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
