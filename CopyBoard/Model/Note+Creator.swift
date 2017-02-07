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
        if DBManager.shared.queryNotes().count > 20 {
            return
        }
        
        let note1 = Note()
        note1.noteCreator(content: "deslfksf;sakjflsajflk;sajfkl;jsalk;fjsal;kfjls;kajflk;sadjflksajflksajfl;ksajfl;safjl;ksajflksadjflksajdfl;safjlk;sajfl;ksdfjf", createdAt: Date())
        note1.color = 0
        
        let note2 = Note()
        note2.noteCreator(content: "deslfksf;sakjflsajflk;sajfkl;jsalk;fjsal;kfjls;kajflk;sadjflksajflksajfl;ksajfl;safjl;ksajflksadjflksajdfl;safjlk;sajfl;ksdfjf", createdAt: Date() - 2.days)
        note2.color = 1
        
        let note3 = Note()
        note3.noteCreator(content: "gsfsa;fksa;ldfk;slakf;safks;afsjadhfsdahfsahfjksladhfjksadhkfljhi",
                          createdAt: Date() - 5.days)
        note3.color = 2
        
        let note4 = Note()
        note4.color = 3
        note4.noteCreator(content: "sfs;flsadj;skadj;lsdgsnm,zxnvm,nzxc,.vn,zx", createdAt: Date() - 4.days)
        
        let note5 = Note()
        var content = "gsfsa;fksa;ldfk;slakf;safks;afsjadhfsdahfsahfjksladhfjksadhkfljhi"
        var createdAt = Date() - 3.days
        note5.noteCreator(content: content, createdAt: createdAt)
        note5.color = 4
        
        let note6 = Note()
        content = "fsa;lcvmxcmv.xncmv,"
        createdAt = Date() - 1.days
        note6.noteCreator(content: content, createdAt: createdAt)
        note6.color = 5
        
        let note7 = Note()
        content = "asfl;f"
        createdAt = Date() - 6.days
        note7.noteCreator(content: content, createdAt: createdAt)
        
        let note8 = Note()
        content = "F;ASLFJNM,XNVMXCV"
        createdAt = Date() - 7.days
        note8.noteCreator(content: content, createdAt: createdAt)
        
        let note9 = Note()
        content = "sd;fkslvzxcmv"
        createdAt = Date() - 8.days
        note9.noteCreator(content: content, createdAt: createdAt)
        
        DBManager.shared.writeObjects(notify: false, objects: [note1, note2, note3, note4, note5, note6, note7, note8, note9])
    }
    
    #endif

}
