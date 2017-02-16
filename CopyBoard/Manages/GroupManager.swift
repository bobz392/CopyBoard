//
//  AppGroupUserDefault.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/12.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation

let GroupIdentifier = "group.com.zhoubo.CopyBoard"

/**
 把任意一个对象转化为一个**group**的数据结构为一个包含着**字典的数组**，所以可以选择把这个数组做后续操作。
 - userdefault
 - icloud
 */
struct GroupManager {
    typealias GroupArray = [Dictionary<String, String>]

    func createDictArray(objects: [ObjectMirrorDelegate]) -> GroupArray? {
        guard let saveKeys = objects.first?.objectValueKeys()
            else { return nil }
        
        var valuesDictArray = GroupArray()
        
        for obj in objects {
            let objMirror = Mirror(reflecting: obj)
            var valuesDict = [String: String]()
            objMirror.children.filter({ (child) -> Bool in
                guard let label = child.label else { return false }
                return saveKeys.contains(label)
            }).forEach({ (child) in
                guard let label = child.label
                    else { fatalError("filter values contains nil value label")}
                
                if let value = obj.transformational(label: label) {
                    valuesDict[label] = value
                } else {
                    valuesDict[label] = "\(child.value)"
                }
            })
            
            if valuesDict.count > 0 {
                valuesDictArray.append(valuesDict)
            }
        }
        
        return valuesDictArray
    }
    
}

protocol ObjectMirrorDelegate {
    func childTypes() -> [Any.Type]
    func objectValueKeys() -> Array<String>
    func transformational(label: String) -> String?
}
