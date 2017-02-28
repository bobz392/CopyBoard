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
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            privateDatabase.fetch(withRecordID: deleteRecordID) { (record, error) in
                if let _ = record {
                    privateDatabase.delete(withRecordID: deleteRecordID, completionHandler: { (recordID, error) in
                        if error == nil {
                            dispatch_async_main {
                                DBManager.shared.deleteObject(note)
                                AppSettings.shared.lastSync = Date()
                            }
                            Logger.log("delete note success")
                        } else {
                            Logger.log("delete note failed")
                        }
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            privateDatabase.fetch(withRecordID: recordId) { [unowned self] (record, error) in
                let updateRecord: CKRecord
                if let re = record {
                    updateRecord = re
                } else {
                    updateRecord = CKRecord(recordType: "Note", recordID: recordId)
                }
                
                let realm = try! Realm()
                guard let n = realm.resolve(noteRef) else {
                    Logger.log("update realm resolve failed")
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    return
                }
                
                self.config(record: updateRecord, byNote: n)
                privateDatabase.save(updateRecord, completionHandler: { (record, error) in
                    var createdSuccess = true
                    if record == nil, error != nil {
                        createdSuccess = false
                        Logger.log("update note failed")
                    }
                    Logger.log("update note success")
                    dispatch_async_main {
                        DBManager.shared.updateObject {
                            note.updateCloud = createdSuccess
                        }
                        AppSettings.shared.lastSync = Date()
                    }
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                })
                
            }
        }
    }
    
    func syncOfflineDataFromCloud() {
        self.enable {
            let privateDatabase = CKContainer.default().privateCloudDatabase
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            let predicate = NSPredicate(format: "modificationDate > %@", AppSettings.shared.lastSync as NSDate)
            let query = CKQuery(recordType: "Note", predicate: predicate)
            privateDatabase.perform(query, inZoneWith: nil, completionHandler: { [unowned self] (records, error) in
                if let records = records {
                    let realm = try! Realm()
                    let allNotes = realm.objects(Note.self)
                    Logger.log("offline notes \(records)")
                    for record in records {
                        if let syncNote = self.configToNoteBy(record: record) {
                            realm.beginWrite()
                            if let note = allNotes.filter("uuid = '\(record.recordID.recordName)'").first {
//                                if note.modificationDate?.isBefore(date: <#T##Date#>, granularity: Calendar.Component.calendar) {
//                                }
                                note.modificationDate = syncNote.modificationDate
                                note.color = syncNote.color
                                note.favourite = syncNote.favourite
                                note.modificationDevice = syncNote.modificationDevice
                                note.content = syncNote.content
                                note.updateCloud = true
                            } else {
                                syncNote.updateCloud = true
                                realm.add(syncNote)
                            }
                            try! realm.commitWrite()
                        }
                    }
                } else {
                    Logger.log("no offline note")
                }
                
                dispatch_async_main { [unowned self] in 
                    self.retry()
                    AppSettings.shared.lastSync = Date()
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
            
            
        }
    }
    
    fileprivate func retry() {
        let waitDeleteNotes = DBManager.shared.queryRetryNotes()
        Logger.log("wait update Notes = \(waitDeleteNotes)")
        
        for n in waitDeleteNotes {
            if n.deleteCloud == true {
                self.delete(note: n)
            }
            
            if n.updateCloud == false {
                self.update(note: n)
            }
        }
    }
    
    func createSubscription() {
        let predicate = NSPredicate(value: true)
        CKContainer.default().privateCloudDatabase.fetchAllSubscriptions { (subscriptions, error) in
            if let _ = subscriptions {
                Logger.log("subscription extist avoid recreate it")
            } else {
                let subscription = CKSubscription(recordType: "Note", predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion])
                let notificationInfo = CKNotificationInfo()
                notificationInfo.shouldSendContentAvailable = true
                subscription.notificationInfo = notificationInfo
                CKContainer.default().privateCloudDatabase.save(subscription) { (subscription, error) in
                    Logger.log("subscription = \(subscription), error = \(error)")
                }
            }
        }
    }
    
    func asyncFromCloud() {
        guard DBManager.shared.queryNotes().count <= 0 else {
            return
        }
        
        let privateDatabase = CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: "Note", predicate: NSPredicate(value: true))
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        privateDatabase.perform(query, inZoneWith: nil) { [unowned self] (records, error) in
            if let allRecords = records {
                let notes = allRecords.flatMap ({ (record) -> Note? in
                    return self.configToNoteBy(record: record)
                })
                
                dispatch_async_main {
                    DBManager.shared.writeObjects(objects: notes)
                }
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    fileprivate func configToNoteBy(record: CKRecord) -> Note? {
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
            note.updateCloud = true
            
            return note
        } else {
            return nil
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
    
    fileprivate func updateNoteFromRemote(record: CKRecord, reason: CKQueryNotificationReason) {
        guard let content = record["content"] as? String,
            let modificationDevice = record["modificationDevice"] as? String,
            let modificationDate = record["modificationDate"] as? Date,
            let favourite = (record["favourite"] as? NSNumber)?.boolValue,
            let color = (record["color"] as? NSNumber)?.intValue,
            let createdAt = record["createdAt"] as? Date else {
                Logger.log("update note from icloud but format not correct")
                return
        }
        
        dispatch_async_main {
            var note: Note?
            if reason == .recordCreated {
                let n = Note()
                n.uuid = record.recordID.recordName
                DBManager.shared.writeObject(n)
                note = n
            } else {
                note = DBManager.shared.querySpecificNoteBy(uuid: record.recordID.recordName)
            }
            
            if let note = note {
                DBManager.shared.updateObject {
                    note.updateCloud = true
                    note.content = content
                    note.modificationDate = modificationDate
                    note.modificationDevice = modificationDevice
                    note.color = color
                    note.createdAt = createdAt
                    note.favourite = favourite
                }
            }
        }
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
    
    func handleNotification(userInfo: [AnyHashable: Any]) {
        let cn = CKNotification(fromRemoteNotificationDictionary: userInfo)
        if cn.notificationType == CKNotificationType.query {
            if let queryCN = cn as? CKQueryNotification,
                let recordID = queryCN.recordID {
                Logger.log("recordID \(queryCN.recordID)")
                Logger.log("queryNotificationReason \(queryCN.queryNotificationReason.rawValue)")
                switch queryCN.queryNotificationReason {
                case .recordUpdated, .recordCreated:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    CKContainer.default().privateCloudDatabase.fetch(withRecordID: recordID, completionHandler: { [unowned self] (record, error) in
                        Logger.log("query record id = \(recordID) result - \(record), error = \(error)")
                        if let record = record {
                            self.updateNoteFromRemote(record: record, reason: queryCN.queryNotificationReason)
                            dispatch_async_main {
                                AppSettings.shared.lastSync = Date()
                            }
                        }
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    })
                    
                case .recordDeleted:
                    if let note = DBManager.shared.querySpecificNoteBy(uuid: recordID.recordName) {
                        DBManager.shared.deleteObject(note)
                        AppSettings.shared.lastSync = Date()
                    }
                }
            }
        }
    }
    
}
