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
    dynamic var color: Int = 0
    
    
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
    note1.content = "abcasdasd;kslfk;sldfjkl;sajflsadflashfjkhsaldjkfhsakjdfhkljsahfkjlsahdfkjshadfkjlhsdkljfhskjladfhksjadhfkjsladhflkjsadhfkjlsadhfkjlsahdfkjlsahdkjf"
    note1.createdAt = Date()
    note1.color = 0
    
    let note2 = Note()
    note2.content = "deslfksf;sakjflsajflk;sajfkl;jsalk;fjsal;kfjls;kajflk;sadjflksajflksajfl;ksajfl;safjl;ksajflksadjflksajdfl;safjlk;sajfl;ksdfjf"
    note2.createdAt = Date() - 2.days
    note2.color = 1
    
    let note3 = Note()
    note3.content = "gsfsa;fksa;ldfk;slakf;safks;afsjadhfsdahfsahfjksladhfjksadhkfljhi"
    note3.createdAt = Date() - 5.days
    note3.color = 2
    
    let note4 = Note()
    note4.content = "sfs;flsadj;skadj;lsdgsnm,zxnvm,nzxc,.vn,zx"
    note4.createdAt = Date() - 4.days
    note4.color = 3
    
    let note5 = Note()
    note5.content = "gsfsa;fksa;ldfk;slakf;safks;afsjadhfsdahfsahfjksladhfjksadhkfljhi"
    note5.createdAt = Date() - 3.days
    note5.color = 4
    
    let note6 = Note()
    note6.content = "fsa;lcvmxcmv.xncmv,"
    note6.createdAt = Date() - 1.days
    note6.color = 5
    
    let note7 = Note()
    note7.content = "asfl;f"
    note7.createdAt = Date() - 6.days
    
    let note8 = Note()
    note8.content = "F;ASLFJNM,XNVMXCV"
    note8.createdAt = Date() - 7.days
    
    let note9 = Note()
    note9.content = "sd;fkslvzxcmv"
    note9.createdAt = Date() - 8.days
    
    DBManager.shared.realm.beginWrite()
    DBManager.shared.realm.add([note1, note2, note3, note4, note5, note6, note7, note8, note9])
    try! DBManager.shared.realm.commitWrite()
    }
    #endif
}
