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
    dynamic var deleteCloud: Bool = false
    dynamic var updateCloud: Bool = false
}
