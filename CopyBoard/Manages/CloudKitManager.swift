//
//  CloudManage.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/25.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation
import CloudKit
import RealmSwift

class CloudKitManager: NSObject {
    
    static let shared = CloudKitManager()
    
    func delete(note: Note) {
        let deleteRecordID = CKRecordID(recordName: note.uuid)
        
        self.enable {
            let privateDatabase = CKContainer.default().privateCloudDatabase
            privateDatabase.fetch(withRecordID: deleteRecordID) { (record, error) in
                if let _ = record {
                    privateDatabase.delete(withRecordID: deleteRecordID, completionHandler: { (recordID, error) in
                        if error == nil {
                            dispatch_async_main {
                                DBManager.shared.deleteObject(note)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func update(note: Note) {
        let recordId = CKRecordID(recordName: note.uuid)
        let noteRef = ThreadSafeReference(to: note)
        
        self.enable {
            let privateDatabase = CKContainer.default().privateCloudDatabase
            privateDatabase.fetch(withRecordID: recordId) { [unowned self] (record, error) in
                let updateRecord: CKRecord
                if let re = record {
                    updateRecord = re
                } else {
                    updateRecord = CKRecord(recordType: "Note", recordID: recordId)
                }
                
                let realm = try! Realm()
                guard let n = realm.resolve(noteRef) else {
                    return
                }
                
                self.config(record: updateRecord, byNote: n)
                privateDatabase.save(updateRecord, completionHandler: { (record, error) in
                    var createdSuccess = true
                    if record == nil, error != nil {
                        createdSuccess = false
                    }
                    
                    dispatch_async_main {
                        DBManager.shared.updateObject {
                            note.updateCloud = createdSuccess
                        }
                    }
                })
                
            }
        }
    }
    
    func retry() {
        let waitDeleteNotes = DBManager.shared.queryRetryNotes()
        Logger.log("waitDeleteNotes = \(waitDeleteNotes)")
        
        for n in waitDeleteNotes {
            if n.deleteCloud == true {
                self.delete(note: n)
            }
            
            if n.updateCloud == false {
                self.update(note: n)
            }
        }
    }
    
    func asyncFromCloud() {
        let predicate = NSPredicate(value: true)
        let subscription = CKSubscription(recordType: "Note", predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion])
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        CKContainer.default().privateCloudDatabase.save(subscription) { (subscription, error) in
            Logger.log("subscription = \(subscription), error = \(error)")
        }
        
        guard DBManager.shared.queryNotes().count <= 0 else {
            return
        }
        
        let privateDatabase = CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: "Note", predicate: NSPredicate(value: true))
        privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let allRecords = records {
                let notes = allRecords.flatMap ({ (record) -> Note? in
                    if let content = record["content"] as? String,
                        let modificationDevice = record["modificationDevice"] as? String,
                        let modificationDate = record["modificationDate"] as? Date,
                        let favourite = (record["favourite"] as? NSNumber)?.boolValue,
                        let color = (record["color"] as? NSNumber)?.intValue,
                        let createdAt = record["createdAt"] as? Date {
                        
                        let note = Note()
                        note.modificationDate = modificationDate
                        note.content = content
                        note.uuid = record.recordID.recordName
                        note.favourite = favourite
                        note.color = color
                        note.modificationDevice = modificationDevice
                        note.createdAt = createdAt
                        note.updateCloud = false
                        
                        return note
                    } else {
                        return nil
                    }
                })
                
                dispatch_async_main {
                    DBManager.shared.writeObjects(objects: notes)
                }
            }
        }
    }
    
    fileprivate func config(record: CKRecord, byNote note: Note) {
        record["content"] = NSString(string: note.content)
        record["modificationDevice"] = NSString(string: note.modificationDevice)
        record["modificationAt"] = note.modificationDate as NSDate?
        record["favourite"] = NSNumber(booleanLiteral: note.favourite)
        record["color"] = NSNumber(integerLiteral: note.color)
        record["createdAt"] = note.createdAt as NSDate?
    }
    
    fileprivate func enable(block: @escaping () -> Void) {
        CKContainer.default().accountStatus { (status, error) in
            switch status {
            case .available:
                block()
                
            default:
                Logger.log("icloud not enable = \(status), error = \(error)")
                return
            }
        }
    }
    
}
