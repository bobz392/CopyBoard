//
//  DeviceManage.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/2/19.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation

struct DKManager {
    
    static let shared = DKManager()

    var itemSpace: CGFloat {
        get {
            return 4
        }
    }
    
    var columnCount: Int {
        get {
            return isPad ? (isLandscape ? 4 : 3) : (isLandscape ? 3 : 2)
        }
    }
    
    var isPad: Bool {
        get {
            return UIDevice.current.userInterfaceIdiom == .pad
        }
    }
    
    var isLandscape: Bool {
        get {
            let size = UIScreen.main.bounds.size
            return size.height > size.width
        }
    }
    
}

extension UIApplication {
    
    public static func mSharedApplication() -> UIApplication {
        
        guard UIApplication.responds(to: Selector("sharedApplication")) else {
            fatalError("UIApplication.sharedKeyboardApplication(): `UIApplication` does not respond to selector `sharedApplication`.")
        }
        
        
        guard let unmanagedSharedApplication = UIApplication.perform(Selector("sharedApplication")) else {
            fatalError("UIApplication.sharedKeyboardApplication(): `UIApplication.sharedApplication()` returned `nil`.")
        }
        
        guard let sharedApplication = unmanagedSharedApplication.takeUnretainedValue() as? UIApplication else {
            fatalError("UIApplication.sharedKeyboardApplication(): `UIApplication.sharedApplication()` returned not `UIApplication` instance.")
        }
        
        return sharedApplication
    }
    
    public func mOpenURL(url: URL) {
        self.performSelector(onMainThread: Selector("openURL:"), with: url, waitUntilDone: true)
    }
    
}
