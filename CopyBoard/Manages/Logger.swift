//
//  Logger.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/23.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation

struct Logger {
    
    static let queue = DispatchQueue(label: "copy.board.logger", qos: DispatchQoS.background)
    
    static func log(_ log: Any, function: String = #function,
                    file: String = #file, line: Int = #line) {
        #if debug
            queue.sync {
                print("\n")
                print("╔═══════════════════════════════════════════════════════════")
                print("║", function, line)
                print("║", file)
                print("╟───────────────────────────────────────────────────────────")
                print("║ \(log)")
                print("╚═══════════════════════════════════════════════════════════")
                print("\n")
            }
        #endif
    }
}
