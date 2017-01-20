//
//  Note.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/16.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

class Note: Object {
    dynamic var uuid: String = ""
    dynamic var content: String = ""
    dynamic var createdAt: Date? = nil
 
    class func noteCreator(content: String, createdAt: Date? = nil) -> Note {
        let note = Note()
        note.content = content
        note.createdAt = createdAt ?? Date()
        note.uuid = UUIDGenerator.getUUID()
        return note
    }
    
    #if debug
    class func noteTestData() {
        let note1 = Note()
        note1.content = "abc"
        note1.createdAt = Date()
        
        let note2 = Note()
        note2.content = "def"
        note2.createdAt = Date() - 2.days
        
        let note3 = Note()
        note3.content = "ghi"
        note3.createdAt = Date() - 5.days
        
        DBManager.shared.realm.beginWrite()
        DBManager.shared.realm.add([note1, note2, note3])
        try! DBManager.shared.realm.commitWrite()
    }
    #endif
}
