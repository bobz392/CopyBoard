//
//  DBManage+Keyboard.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/25.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

extension DBManager {
    
    func keyboardQueryNotes() -> Results<Note> {
        let settings = AppSettings.shared
        let sortKey = settings.sortKey()
        var all = self.r.objects(Note.self).filter("deleteCloud = false")
        if settings.keyboardFilterStar != 0 {
            all = all.filter("favourite = \(settings.keyboardFilterStar == 1 ? true : false)")
        }
        
        let cs = settings.keyboardFilterColor
        var qc = ""
        for (index, c) in cs.enumerated() {
            qc += "color = \(c)"
            
            if index != cs.count - 1 {
                qc += " OR "
            }
        }
        
        return all.filter(qc).sorted(byKeyPath: sortKey, ascending: false)
    }

}
