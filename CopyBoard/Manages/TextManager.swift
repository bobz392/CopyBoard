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
        let attr = noteAttr()
        
        if let q = query, q.characters.count > 0 {
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
    
    func noteAttr() -> NSMutableAttributedString {
        let attr = NSMutableAttributedString(string: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.lineBreakMode = .byTruncatingMiddle
        
        
        let range = NSMakeRange(0, self.characters.count)
        attr.addAttribute(NSParagraphStyleAttributeName,
                          value: paragraphStyle, range: range)
        attr.addAttribute(NSFontAttributeName, value: appFont(size: 16), range: range)
        
        return attr
    }
    
    func bounding(size: CGSize, font: UIFont) -> CGSize {
//        let label = UILabel(frame: CGRect(center: .zero, size: size))
//        label.numberOfLines = 0
//        label.attributedText = noteAttr()
//        label.font = appFont(size: 16)
//        let size = label.sizeThatFits(size)
//        
        
        
        
        let attr = noteAttr()
        let rect = attr.boundingRect(with: size,
                                     options: [.usesLineFragmentOrigin],
                                     context: nil)
//
        //文本的高度减去字体高度小于等于行间距，判断为当前只有1行
//        if (rect.size.height - font.lineHeight) <= 0 {
//            if self.containChinese() {
//                let size = CGSize(width: rect.size.width, height: rect.size.height)
//                rect = CGRect(origin: rect.origin, size: size)
//            }
//        }
        
        return CGSize(width: rect.width, height: appFont(size: 16).lineHeight * 5)
    }
    
    func containChinese() -> Bool {
        let ns = self as NSString
        for index in 0..<self.characters.count {
            let c = ns.character(at: index)
            if c > 0x4e00, c < 0x9fff {
                return true
            }
        }
        
        return false
    }
    
}
