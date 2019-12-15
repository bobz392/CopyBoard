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
    

    
    var deviceName: String {
        get {
            return UIDevice.current.name
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
    
    var statusOrientation: UIInterfaceOrientationMask {
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
        default:
            return .portrait
        }
    }
    
    
    var isLandscape: Bool {
        get {
            let orient = UIDevice.current.orientation
            if orient == .landscapeLeft || orient == .landscapeRight {
                return true
            } else if orient == .portrait || orient == .portraitUpsideDown {
                return false
            } else {
                let so = UIApplication.shared.statusBarOrientation
                return so.isLandscape
            }
        }
    }
    
    func hiddenStatusBar(hidden: Bool) {
        guard !self.isLandscape else { return }
        UIApplication.shared
            .setStatusBarHidden(hidden, with: .slide)
    }
    
    var mainHeight: CGFloat {
        get {
            return self.statusbarHeight + self.navigationBarHeight
        }
    }
    
    var statusbarHeight: CGFloat {
        get {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    var navigationBarHeight: CGFloat {
        get {
            return isLandscape ? 32 : 44
        }
    }
    
    var noteColumnCount: Int {
        get {
            return isPad ? (isLandscape ? 4 : 3) : (isLandscape ? 3 : 2)
        }
    }
    
    var collectionViewItemSpace: CGFloat {
        return self.isPhone ? 12.0 : 18.0
    }
    
    
}

enum PhoneScreenType {
    case phone5
    case phone6
    case phone6p
}
