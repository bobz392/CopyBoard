//
//  UserDefaultsManager.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/13.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation

struct UserDefaultsManager {
    let groupUserDefault: UserDefaults

    init?(identifier: String? = nil) {
        guard let groupDefault = UserDefaults(suiteName: identifier) else {
            return nil
        }

        self.groupUserDefault = groupDefault
    }
    
    init() {
        self.groupUserDefault = UserDefaults.standard
    }
    
    func saveToUserDefault(objects: [ObjectMirrorDelegate], forKey key: String) {
        guard let valuesDictArray = GroupManager().createDictArray(objects: objects)
            else { return }
        
        self.groupUserDefault.set(valuesDictArray, forKey: key)
        self.groupUserDefault.synchronize()
    }
    
    func readGroupFromUserDefault(forKey key: String) -> [Dictionary<String, String>]? {
        return self.groupUserDefault.object(forKey: key) as? [Dictionary<String, String>]
    }
    
    func write(_ key: String, value: Any) {
        self.groupUserDefault.set(value, forKey: key)
        self.groupUserDefault.synchronize()
    }
    
    func readBool(_ key: String) -> Bool {
        return self.groupUserDefault.bool(forKey: key)
    }
    
    func readString(_ key: String) -> String? {
        return self.groupUserDefault.string(forKey: key)
    }
    
    func readInt(_ key: String) -> Int {
        return self.groupUserDefault.integer(forKey: key)
    }
    
    func readArray(_ key: String)-> Array<Any>? {
        return self.groupUserDefault.array(forKey: key)
    }
    
    func remove(_ key: String) {
        self.groupUserDefault.removeObject(forKey: key)
        self.groupUserDefault.synchronize()
    }
    
}
