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
    @objc dynamic var uuid: String = ""
    @objc dynamic var content: String = ""
    @objc dynamic var createdAt: Date? = nil
    @objc dynamic var modificationDate: Date? = nil
    @objc dynamic var modificationDevice: String = ""
    @objc dynamic var color: Int = 0
    @objc dynamic var favourite: Bool = false
    // false 代表不需要删除
    @objc dynamic var isDelete: Bool = false
    // false 代表需要同步，反之则不需要
    @objc dynamic var updateCloud: Bool = false
    @objc dynamic var category: String? = nil
    
    class func createDefaultNote() -> [String] {
        return [Localized("defaultNote1"), Localized("defaultNote2"), Localized("defaultNote3"), Localized("defaultNote4"), Localized("defaultNote5")]
    }
}
