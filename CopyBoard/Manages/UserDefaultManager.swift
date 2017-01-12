//
//  UserDefaultManager.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/13.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation

struct UserDefaultManager {
    let userDefault: UserDefaults
    
    init?(suiteName: String) {
        guard let userDefault = UserDefaults(suiteName: suiteName) else {
            return nil
        }
        
        self.userDefault = userDefault
    }
    
    init() {
        self.userDefault = UserDefaults.standard
    }
    
    func saveToUserDefault(objects: [ObjectMirrorDelegate], forKey key: String) {
        guard let valuesDictArray = GroupManager().createDictArray(objects: objects)
            else { return }
        
        self.userDefault.set(valuesDictArray, forKey: key)
        self.userDefault.synchronize()
    }
    
    func readGroudFromUserDefault(forKey key: String) -> [Dictionary<String, String>]? {
        return self.userDefault.object(forKey: key) as? [Dictionary<String, String>]
    }
    
    func write(_ key: String, value: Any) {
        self.userDefault.set(value, forKey: key)
        self.userDefault.synchronize()
    }
    
    func readBool(_ key: String) -> Bool {
        return self.userDefault.bool(forKey: key)
    }
    
    func readString(_ key: String) -> String? {
        return self.userDefault.string(forKey: key)
    }
    
    func readInt(_ key: String) -> Int {
        return self.userDefault.integer(forKey: key)
    }
    
    func readArray(_ key: String)-> Array<Any>? {
        return self.userDefault.array(forKey: key)
    }
    
    func remove(_ key: String) {
        self.userDefault.removeObject(forKey: key)
        self.userDefault.synchronize()
    }
    
}
