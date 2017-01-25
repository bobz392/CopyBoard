//
//  TextManager.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/24.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation

func Localized(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

func appFont(size: CGFloat, weight: CGFloat = UIFontWeightRegular) -> UIFont {
    return UIFont.systemFont(ofSize: size, weight: weight)
}

func emptyNotesFont() -> CGFloat {
    let dm = DeviceManager.shared
    
    if dm.isPhone() {
        switch dm.phoneScreenType() {
        case .phone5:
            return 18
        case .phone6:
            return 20
        case .phone6p:
            return 24
        }
    } else {
        return 0
    }
}

extension String {
    func searchHintString(query: String? = nil) -> NSAttributedString {
        let attr = NSMutableAttributedString(string: self,
                                             attributes: [NSFontAttributeName: appFont(size: 16)])
        if let q = query {
            let pattern = "\(q)"
            let regular = try! NSRegularExpression(pattern: pattern, options:.caseInsensitive   )
            let results = regular.matches(in: self, options: .reportProgress , range: NSMakeRange(0, self.characters.count))
            Logger.log("\(results.count) match use \(query)")
            for result in results {
                attr.addAttributes([NSBackgroundColorAttributeName: AppColors.searchText], range: result.range)
            }
            
            return attr
        } else {
            return attr
        }
    }
    
}
