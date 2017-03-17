//
//  TextManager.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/24.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

func Localized(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

func appFont(size: CGFloat, weight: CGFloat = UIFontWeightRegular) -> UIFont {
    if currentPreferrenLang()?.hasPrefix("en") == true,
        let font = UIFont(name: "Avenir Next", size: size) {
        return font
    } else {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}

extension UILabel {
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.font = appFont(size: self.font.pointSize)
    }
}

func currentPreferrenLang() -> String? {
    return UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String
}

extension String {
    
    func searchHintString(isTruncated: Bool, query: String? = nil) -> NSAttributedString {
        if let q = query, q.characters.count > 0 {
            let pattern = "\(q)"
            let regular =
                try! NSRegularExpression(pattern: pattern, options:.anchorsMatchLines)
            let results = regular.matches(in: self, options: .reportProgress , range: NSMakeRange(0, self.characters.count))
            
            let str: String
            var jumpIndex = 0
            if let location = results.first?.range.location, isTruncated == true {
                let index = self.index(self.startIndex, offsetBy: location)
                str = "...\(self.substring(from: index))"
                jumpIndex = location - 3
            } else {
                str = self
            }
            let attr = str.noteAttr()
            
            for result in results {
                let range = jumpIndex <= 0 ? result.range :
                    NSMakeRange(result.range.location - jumpIndex, result.range.length)
                attr.addAttributes([NSBackgroundColorAttributeName: AppColors.searchText], range: range)
            }
            
            return attr
        } else {
            return noteAttr()
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
    
    
//    func bounding(size: CGSize, font: UIFont) -> CGSize {
//        let label = UILabel(frame: CGRect(center: .zero, size: size))
//        label.numberOfLines = 0
//        label.attributedText = noteAttr()
//        label.font = appFont(size: 16)
//        let size = label.sizeThatFits(size)
//        
        
        
        
//        let attr = noteAttr()
//        let rect = attr.boundingRect(with: size,
//                                     options: [.usesLineFragmentOrigin],
//                                     context: nil)
//
        //文本的高度减去字体高度小于等于行间距，判断为当前只有1行
//        if (rect.size.height - font.lineHeight) <= 0 {
//            if self.containChinese() {
//                let size = CGSize(width: rect.size.width, height: rect.size.height)
//                rect = CGRect(origin: rect.origin, size: size)
//            }
//        }
        
//        return CGSize(width: rect.width, height: appFont(size: 16).lineHeight * 5)
//    }
    
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

    func segmentation() -> [SegmenttationItem] {
        var tokens = [SegmenttationItem]()
        
        if let range = range(of: self) {
            self.enumerateSubstrings(in: range, options: String.EnumerationOptions.byWords) { (string, start, end, b) in
                if let s = string, s != " " {
                    let seg = SegmenttationItem(content: s, inUse: true)
                    tokens.append(seg)
                }
            }
        }
        
//        let locale = CFLocaleCopyCurrent()
//        let cfString = self as CFString
//        let range = CFRangeMake(0, CFStringGetLength(cfString))
//        
//        let tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, cfString, range, kCFStringTokenizerUnitWord, locale)
//        
//        
        
        return tokens
    }
    
}

struct SegmenttationItem {
    var content: String
    var inUse: Bool
}
