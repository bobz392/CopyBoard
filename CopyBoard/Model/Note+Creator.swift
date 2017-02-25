//
//  Note+Creator.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/7.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation

extension Note {
    
    @discardableResult
    func noteCreator(content: String, createdAt: Date? = nil) -> Note {
        self.content = content
        self.createdAt = createdAt ?? Date()
        self.modificationDate = self.createdAt
        self.modificationDevice = DeviceManager.shared.deviceName
        self.uuid = UUIDGenerator.getUUID()
        return self
    }
    
    #if debug
    
    class func noteTestData() {
//        if DBManager.shared.queryNotes().count > 0 {
            return
//        }
        
        let note1 = Note()
        note1.noteCreator(content: "Work makes the workman.", createdAt: Date())
        note1.color = 0
        
        let note2 = Note()
        note2.noteCreator(content: "We grow neither better nor worse as we grow old but more and more like ourselves.", createdAt: Date() - 2.days)
        note2.color = 1
        
        let note3 = Note()
        note3.noteCreator(content: "A handful of common sense is worth a bushel of learning.",
                          createdAt: Date() - 5.days)
        note3.color = 2
        
        let note4 = Note()
        note4.color = 3
        note4.noteCreator(content: "Business is the salt of life.", createdAt: Date() - 4.days)
        
        let note5 = Note()
        var content = "It is not work that kills,but worry."
        var createdAt = Date() - 3.days
        note5.noteCreator(content: content, createdAt: createdAt)
        note5.color = 4
        
        let note6 = Note()
        content = "Nothing in life is to be feared. It is only to be understood."
        createdAt = Date() - 1.days
        note6.noteCreator(content: content, createdAt: createdAt)
        note6.color = 5
        
        let note7 = Note()
        content = "Do business,but be not a slave to it."
        createdAt = Date() - 6.days
        note7.noteCreator(content: content, createdAt: createdAt)
        
        let note8 = Note()
        content = "Better late than never."
        createdAt = Date() - 7.days
        note8.noteCreator(content: content, createdAt: createdAt)
        
        let note9 = Note()
        content = "Finished labours are pleasant."
        createdAt = Date() - 8.days
        note9.noteCreator(content: content, createdAt: createdAt)
        
        DBManager.shared.writeObjects(notify: false, objects: [note1, note2, note3, note4, note5, note6, note7, note8, note9])
    }

    class func addNote(row: Int) {
        let note = Note()
        note.noteCreator(content: "row \(row)", createdAt: Date())
        note.color = 0
        DBManager.shared.writeObject(note)
        
    }
    
    #endif

}
