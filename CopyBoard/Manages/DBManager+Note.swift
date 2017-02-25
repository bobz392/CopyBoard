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
    
    func querySpecificNoteBy(uuid: String) -> Note? {
        return self.r.objects(Note.self).filter("uuid = '\(uuid)'").first
    }
    
    func queryNotes(contain: String? = nil) -> Results<Note> {
        let sortKey = AppSettings.shared.sortKey()
        let ascending = AppSettings.shared.sortNewestLast
        let queryAll = self.r.objects(Note.self).filter("deleteCloud = false")
        if let contain = contain {
            let query = AppSettings.shared.caseSensitiveQuery(key: "content", value: contain)
            return queryAll.filter(query)
                .sorted(byKeyPath: sortKey, ascending: ascending)
        } else {
            return queryAll.sorted(byKeyPath: sortKey, ascending: ascending)
        }
    }
    
    func queryRetryNotes() -> Results<Note> {
        return self.r.objects(Note.self).filter("deleteCloud = true OR updateCloud = false")
    }
    
    func updateNote(notify: Bool = true, note: Note, updateBlock: @escaping () -> Void) {
        Logger.log("update note = \(note), notify = \(notify)")
        self.updateObject(notify) { 
            note.updateCloud = true
            updateBlock()
        }
    
        CloudKitManager.shared.update(note: note)
    }
    
    func deleteNote(note: Note) {
        self.updateObject {
            note.deleteCloud = true
        }
        Logger.log("prepar delete note = \(note)")
        CloudKitManager.shared.delete(note: note)
    }
}
