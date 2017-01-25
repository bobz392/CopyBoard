//
//  Convenient.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/25.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation

/**
 延迟若干秒。
 */
func dispatchDelay(_ seconds: TimeInterval, closure: @escaping () -> Void) {
    let delta = Int64(seconds * TimeInterval(NSEC_PER_SEC))
    let delayTime = DispatchTime.now() + Double(delta) / Double(NSEC_PER_SEC)
    let queue = DispatchQueue.main
    queue.asyncAfter(deadline: delayTime, execute: closure)
}

func dispatch_async_main(_ closure: @escaping () -> Void) {
    DispatchQueue.main.async(execute: closure)
}

func dispatch_global_async(_ closure: @escaping () -> Void) {
    let queue = DispatchQueue.global()
    queue.async {
        closure()
    }
}
