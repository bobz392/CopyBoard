//
//  QuickActionDispatcher.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/3/4.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation

enum QuickActionType: String {
    case create = "com.zhoubo.copyboard.new"
    case search = "com.zhoubo.copyboard.search"
    //    case setting = "com.zhoubo.copyboard.settings"
}


@available(iOS 9.0, *)
struct QuickActionDispatcher {
    
    typealias QuickActionCompletion = (Bool) -> Void
    
    func dispatch(_ shortcutItem: UIApplicationShortcutItem, completion: QuickActionCompletion) {
        guard let navc = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController,
            let vc = navc.viewControllers.first as? NotesViewController else { return }
        vc.dismiss(animated: false, completion: nil)
        
        switch shortcutItem.type {
        case QuickActionType.create.rawValue:
            vc.createAction()
            
        case QuickActionType.search.rawValue:
            vc.searchAction()
            
        default:
            break
        }
    }
   
}
