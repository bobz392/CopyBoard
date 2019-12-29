//
//  KeyboardManager.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/29.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

final class KeyboardManager {
    typealias KeyboardHandle = (_ show: Bool,
        _ height: CGFloat,
        _ duration: Double) -> Void
    
    static let shared = KeyboardManager()
    
    fileprivate var keyboardHandler: KeyboardHandle?
    
    init() {
        weak var ws = self
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: OperationQueue.main) { notification in
                ws?.handleKeyboardShow(notification)
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: OperationQueue.main) { notification in
                ws?.handleKeyboardHide(notification)
        }
    }
    
    func setHander(handle: @escaping KeyboardHandle) {
        self.keyboardHandler = handle
    }
    
    func removeHander() {
        self.keyboardHandler = nil
    }
    
    fileprivate func handleKeyboardShow(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo,
            let frameValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let durationValue = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            Logger.log("change frame height to \(frameValue.height)")
            if frameValue.height > 0 {
                self.keyboardHandler?(true, frameValue.height, durationValue)
            }
        }
    }
    
    fileprivate func handleKeyboardHide(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo,
            let durationValue = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            self.keyboardHandler?(false, 0, durationValue)
        }
    }
}
