//
//  DBManager+Note.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/25.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

extension DBManager {
    
    func unbindNotify() {
        self.notesToken?.invalidate()
        self.dataSource = nil
    }
    
    func bindNotifyToken<T>(result: Results<T>, dataSource: RealmNotificationDataSource) {
        self.dataSource = dataSource
        self.notesToken = result.observe { (changes: RealmCollectionChange) in
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
    
    func querySpecificNoteBy(uuid: String) -> Note? {
        return self.r.objects(Note.self).filter("uuid = '\(uuid)'").first
    }
    
    func queryNotes(contain: String? = nil, color: Int? = nil) -> Results<Note> {
        let sortKey = AppSettings.shared.sortKey()
        let ascending = AppSettings.shared.sortNewestLast
        let predict: String
        if let c = color {
            predict = "isDelete = false AND color = \(c)"
        } else {
            predict = "isDelete = false"
        }
        let queryAll = r.objects(Note.self).filter(predict)
        if let contain = contain {
            let query = AppSettings.shared
                .caseSensitiveQuery(key: "content", value: contain)
            return queryAll.filter(query)
                .sorted(byKeyPath: sortKey, ascending: ascending)
        } else {
            return queryAll.sorted(byKeyPath: sortKey, ascending: ascending)
        }
    }
    
    func queryRetryNotes() -> Results<Note> {
        return self.r.objects(Note.self).filter("updateCloud = false")
    }
    
    func queryCheckRemoteNotes() -> Results<Note> {
        let predicate = NSPredicate(format: "modificationDate > %@", AppSettings.shared.lastSync as NSDate)
        return self.r.objects(Note.self).filter(predicate)
    }
    
    func updateNote(notify: Bool = true, note: Note, updateBlock: @escaping () -> Void) {
        Logger.log("update note = \(note), notify = \(notify)")
        self.updateObject(notify) { 
            note.updateCloud = true
            updateBlock()
        }
    
        CloudKitManager.shared.update(note: note)
    }
    
    func writeNote(note: Note) {
        Logger.log("create note = \(note)")
        self.writeObject(note)
        
        CloudKitManager.shared.update(note: note)
    }
    
    func deleteNote(note: Note) {
        self.updateObject {
            note.isDelete = true
        }
        Logger.log("prepar delete note = \(note)")
        CloudKitManager.shared.update(note: note)
    }
    
}
