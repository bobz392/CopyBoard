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
    dynamic var modificationDate: Date? = nil
    dynamic var modificationDevice: String = ""
    dynamic var color: Int = 0
    dynamic var favourite: Bool = false
    // false 代表不需要删除
    dynamic var deleteCloud: Bool = false
    // false 代表需要同步，反之则不需要
    dynamic var updateCloud: Bool = false
}
