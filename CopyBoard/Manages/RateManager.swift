//
//  RateManager.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/22.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation

struct RateManager {
    func configRate() {
        iRate.sharedInstance().onlyPromptIfLatestVersion = true
        iRate.sharedInstance().useUIAlertControllerIfAvailable = true
    }
}
