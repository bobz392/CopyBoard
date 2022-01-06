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
    
//    func delete(note: Note) {
//        let deleteRecordID = CKRecordID(recordName: note.uuid)
//        
//        self.enable {
//            let privateDatabase = CKContainer.default().privateCloudDatabase
//            UIApplication.shared.isNetworkActivityIndicatorVisible = true
//            privateDatabase.fetch(withRecordID: deleteRecordID) { (record, error) in
//                if let _ = record {
//                    privateDatabase.delete(withRecordID: deleteRecordID, completionHandler: { (recordID, error) in
//                        if error == nil {
//                            dispatch_async_main {
//                                AppSettings.shared.lastSync = Date()
//                            }
//                            Logger.log("delete note success")
//                        } else {
//                            Logger.log("delete note failed")
//                        }
//                        
//                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                    })
//                }
//            }
//        }
//    }
    
    func update(note: Note) {
        let recordId = CKRecord.ID(recordName: note.uuid)
        let noteRef = ThreadSafeReference(to: note)
        
        self.enable {
            let privateDatabase = CKContainer.default().privateCloudDatabase
           
            dispatch_async_main {
                UIApplication.shared
                    .isNetworkActivityIndicatorVisible = true
            }
            
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
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                })
                
            }
        }
    }
    
    func syncOfflineDataFromCloud() {
        self.enable {
            let privateDatabase = CKContainer.default().privateCloudDatabase
            dispatch_async_main {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            
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
                                note.modificationDate = syncNote.modificationDate
                                note.color = syncNote.color
                                note.favourite = syncNote.favourite
                                note.createdAt = syncNote.createdAt
                                note.modificationDevice = syncNote.modificationDevice
                                note.isDelete = syncNote.isDelete
                                note.content = syncNote.content
                                note.updateCloud = true
                                note.category = syncNote.category
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
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })
            
        }
    }

    fileprivate func retry() {
        let waitDeleteNotes = DBManager.shared.queryRetryNotes()
        Logger.log("wait update Notes = \(waitDeleteNotes)")
        
        for n in waitDeleteNotes {
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
                let subscription =
                CKQuerySubscription(recordType: "Note",
                                   predicate: predicate,
                                   options: [.firesOnRecordCreation,
                                             .firesOnRecordUpdate,
                                             .firesOnRecordDeletion])
                let notificationInfo = CKSubscription.NotificationInfo()
                notificationInfo.shouldSendContentAvailable = true
                subscription.notificationInfo = notificationInfo
                CKContainer.default().privateCloudDatabase.save(subscription) { (subscription, error) in
                    let nilText = "nil"
                    Logger.log("subscription = \(subscription.debugDescription), error = \(error?.localizedDescription ?? nilText)")
                }
            }
        }
    }
    
    func asyncFromCloud() {
        guard DBManager.shared.queryNotes().count <= 0 else {
            dispatch_async_main {
                Note.createDefaultDBNote()
            }
            return
        }
        
        let privateDatabase = CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: "Note", predicate: NSPredicate(value: true))
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        privateDatabase.perform(query, inZoneWith: nil) { [unowned self] (records, error) in
            if let allRecords = records, allRecords.count > 0 {
                let notes = allRecords.compactMap ({ (record) -> Note? in
                    return self.configToNoteBy(record: record)
                })
                
                dispatch_async_main {
                    DBManager.shared.writeObjects(objects: notes)
                }
            } else {
                dispatch_async_main {
                    Note.createDefaultDBNote()
                }
            }
            
            dispatch_async_main {
                AppSettings.shared.appSetup = true
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    fileprivate func configToNoteBy(record: CKRecord) -> Note? {
        if let content = record["content"] as? String,
            let favourite = (record["favourite"] as? NSNumber)?.boolValue,
            let isDelete = (record["isDelete"] as? NSNumber)?.boolValue,
            let color = (record["color"] as? NSNumber)?.intValue {
            
            let category = record["catelogue"] as? String
            let createdAt = record["createdAt"] as? Date
            let modificationDevice = record["modifiedByDevice"] as? String
            let modificationDate = record["modificationAt"] as? Date
            
            let note = Note()
            note.modificationDate = modificationDate ?? Date()
            note.content = content
            note.uuid = record.recordID.recordName
            note.favourite = favourite
            note.color = color
            note.modificationDevice = modificationDevice ?? DeviceManager.shared.deviceName
            note.isDelete = isDelete
            note.createdAt = createdAt ?? Date()
            note.updateCloud = true
            note.category = category
            
            return note
        } else {
            return nil
        }

    }
    
    fileprivate func config(record: CKRecord, byNote note: Note) {
        record["content"] = NSString(string: note.content)
        if let category = note.category {
            record["catelogue"] = NSString(string: category)
        }
        record["modificationAt"] = note.modificationDate as NSDate?
        record["favourite"] = NSNumber(booleanLiteral: note.favourite)
        record["color"] = NSNumber(integerLiteral: note.color)
        record["createdAt"] = note.createdAt as NSDate?
        record["isDelete"] = NSNumber(booleanLiteral: note.isDelete)
    }
    
    fileprivate func updateNoteFromRemote(record: CKRecord, reason: CKQueryNotification.Reason) {
        guard let content = record["content"] as? String,
            let modificationDevice = record["modifiedByDevice"] as? String,
            let modificationDate = record["modificationAt"] as? Date,
            let favourite = (record["favourite"] as? NSNumber)?.boolValue,
            let color = (record["color"] as? NSNumber)?.intValue,
            let isDelete = (record["isDelete"] as? NSNumber)?.boolValue,
            let createdAt = record["createdAt"] as? Date else {
                Logger.log("update note from icloud but format not correct")
                return
        }
        
        let category = record["catelogue"] as? String
        
        dispatch_async_main {
            let block = { (note: Note) -> Void in
                note.updateCloud = true
                note.content = content
                note.modificationDate = modificationDate
                note.modificationDevice = modificationDevice
                note.color = color
                note.createdAt = createdAt
                note.favourite = favourite
                note.isDelete = isDelete
                note.category = category
            }
            
            if reason == .recordCreated {
                let n = Note()
                n.uuid = record.recordID.recordName
                block(n)
                DBManager.shared.writeObject(n)
            } else {
                if let note =
                    DBManager.shared.querySpecificNoteBy(uuid: record.recordID.recordName) {
                    DBManager.shared.updateObject {
                        block(note)
                    }
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
                Logger.log("icloud not enable = \(status), error = \(error?.localizedDescription ?? "nil")")
                return
            }
        }
    }
    
    func handleNotification(userInfo: [AnyHashable: Any]) {
        let cn = CKNotification(fromRemoteNotificationDictionary: userInfo)
        if cn?.notificationType == CKNotification.NotificationType.query {
            if let queryCN = cn as? CKQueryNotification,
                let recordID = queryCN.recordID {
                Logger.log("recordID \(queryCN.recordID.debugDescription)")
                Logger.log("queryNotificationReason \(queryCN.queryNotificationReason.rawValue)")
                switch queryCN.queryNotificationReason {
                case .recordUpdated, .recordCreated:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    CKContainer.default().privateCloudDatabase.fetch(withRecordID: recordID, completionHandler: { [unowned self] (record, error) in
                        Logger.log("query record id = \(recordID.debugDescription) result - \(record.debugDescription), error = \(error?.localizedDescription ?? "nil")")
                        if let record = record {
                            self.updateNoteFromRemote(record: record, reason: queryCN.queryNotificationReason)
                            dispatch_async_main {
                                AppSettings.shared.lastSync = Date()
                            }
                        }
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    })
                    
//                case .recordDeleted:
//                    if let note = DBManager.shared.querySpecificNoteBy(uuid: recordID.recordName) {
//                        DBManager.shared.deleteObject(note)
//                        AppSettings.shared.lastSync = Date()
//                    }
                    
                default:
                    return
                }
            }
        }
    }
    
    func downloadHelperMov(name: String, downloadFinishBlock: @escaping (_ url: URL) -> Void) {
        let id = CKRecord.ID(recordName: name)
        Logger.log("download name = \(name)")
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: id) { (record, error) in
            if let record = record,
                let asset = record.object(forKey: "videoDatas") as? CKAsset {
                downloadFinishBlock(asset.fileURL!)
            } else {
                Logger.log("download failed")
            }
        }
    }
}
