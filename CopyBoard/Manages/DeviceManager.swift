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
    
    func phoneScreenType() -> PhoneScreenType {
        let height = UIScreen.main.bounds.height
        if height <= 568 {
            return .phone5
        } else if height <= 667 {
            return .phone6
        } else {
            return .phone6p
        }
    }
    
}

enum PhoneScreenType {
    case phone5
    case phone6
    case phone6p
}
