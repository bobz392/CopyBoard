//
//  KeyboardManager.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/29.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

final class KeyboardManager {
    typealias KeyboardHandle = (Bool) -> Void
    
    static let shared = KeyboardManager()
    static var keyboardHeight: CGFloat = 0
    static var duration: Double = 0.25
    static var keyboardShow: Bool = false
    
    fileprivate var keyboardHandler: KeyboardHandle?
    
    init() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil,
            queue: OperationQueue.main) { notification in
                self.handleKeyboardShow(notification)
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIKeyboardWillHide, object: nil,
            queue: OperationQueue.main) { notification in
                self.handleKeyboardHide(notification)
        }
    }
    
    func setHander(handle: @escaping KeyboardHandle) {
        self.keyboardHandler = handle
    }
    
    func closeNotification() {
        self.keyboardHandler = nil
    }
    
    fileprivate func handleKeyboardShow(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo,
            let frameValue = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let durationValue = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            Logger.log("change frame height to \(frameValue.height)")
            if frameValue.height > 0 {
                KeyboardManager.keyboardHeight = frameValue.height
                KeyboardManager.duration = durationValue > 0 ? durationValue : 0.25
                KeyboardManager.keyboardShow = true
                keyboardHandler?(true)
            }
        }
    }
    
    fileprivate func handleKeyboardHide(_ notification: Notification) {
        keyboardHandler?(false)
        KeyboardManager.keyboardShow = false
    }
}
