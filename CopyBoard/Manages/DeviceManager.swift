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
    
    static var canRotate = false
    
    static var currentOrientation: UIInterfaceOrientationMask {
        let orient = UIApplication.shared.statusBarOrientation
        switch orient {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .unknown:
            return .portrait
        }
    }
    
    var isPhone: Bool {
        get {
            return UIDevice.current.userInterfaceIdiom == .phone
        }
    }

    var isPad: Bool {
        get {
            return UIDevice.current.userInterfaceIdiom == .pad
        }
    }
    
    var isLandscape: Bool {
        get {
            let orient = UIApplication.shared.statusBarOrientation
            return orient == .landscapeLeft || orient == .landscapeRight
        }
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

extension DeviceManager {
    
    var statusbarHeight: CGFloat {
        get {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    var noteColumnCount: Int {
        get {
            return isPad ? (isLandscape ? 4 : 3) : (isLandscape ? 3 : 2)
        }
    }
    
}

enum PhoneScreenType {
    case phone5
    case phone6
    case phone6p
}
