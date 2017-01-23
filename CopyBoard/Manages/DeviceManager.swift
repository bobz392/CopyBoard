//
//  DeviceManager.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/23.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation

struct DeviceManager {
    
    static let shared = DeviceManager()
    
    
    
    func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func isLandscape() -> Bool {
        return UIDevice.current.orientation == .landscapeLeft
            || UIDevice.current.orientation == .landscapeRight
    }
    
}
