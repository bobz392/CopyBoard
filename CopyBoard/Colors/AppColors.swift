//
//  AppColors.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/18.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

struct AppColors {
    
    static let noteText = UIColor(red:0.43, green:0.26, blue:0.19, alpha:1.00)
    static let noteDate = UIColor(red:0.74, green:0.67, blue:0.59, alpha:1.00)
    static let mainIcon = UIColor(red:0.74, green:0.74, blue:0.74, alpha:1.00)
    static let mainBackground = UIColor(red:0.91, green:0.89, blue:0.85, alpha:1.00)
    
    //    static let horizonLine = UIColor(red:0.86, green:0.70, blue:0.42, alpha:1.00)
    //    static let verticalLine = UIColor(red:0.95, green:0.92, blue:0.88, alpha:1.00)
    //    static let noteCell = UIColor(red:0.95, green:0.89, blue:0.67, alpha:1.00)
    
    static let mainGreenColor = UIColor(red:0.09, green:0.63, blue:0.52, alpha:1.00)
    static let cloudColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
    static let separatorColor = UIColor(red:0.74, green:0.76, blue:0.78, alpha:1.00)
    static let lightSeparatorColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.00)
    static let placeHolderTextColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00)
    
    static let systemGreenColor = UIColor(red:0.34, green:0.85, blue:0.42, alpha:1.00)
    
    static let mainBackgroundColor = UIColor(red:0.95, green:0.95, blue:0.97, alpha:1.00)
    static let cellCardColor = UIColor(red:0.99, green:0.99, blue:1.00, alpha:1.00)
    static let cellCardSelectedColor = UIColor(red:0.99, green:0.99, blue:1.00, alpha:0.4)
    static let searchBackgroundColor = UIColor(red:0.96, green:0.89, blue:0.11, alpha:1.00)
    
    static let buttonBackgroundColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
    static let mainTextColor = UIColor(red:0.20, green:0.29, blue:0.37, alpha:1.00)
    static let secondaryTextColor = UIColor(red:0.58, green:0.65, blue:0.65, alpha:1.00)
    
    static let headerTextColor = UIColor(red:0.80, green:0.81, blue:0.85, alpha:1.00)
    
    static let linkButtonTextColor = UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.00)
    static let cellLabelSelectedTextColor = UIColor(red:0.50, green:0.68, blue:0.98, alpha:1.00)
    static let cellSelectedColor = UIColor(red:0.50, green:0.68, blue:0.98, alpha:0.2)
    static let emptyTintColor = UIColor(red:0.70, green:0.72, blue:0.82, alpha:1.00)
    
    static let priorityHighColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.00)
    static let priorityLowColor = UIColor(red:0.95, green:0.77, blue:0.06, alpha:1.00)
    
    static let swipeRedBackgroundColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.00)
    static let swipeBlueBackgroundColor = UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.00)
    
    static let scheduleLineBackgroundColor = UIColor(red:0.75, green:0.78, blue:0.79, alpha:1.00)
    
}

enum AppPairColors: Int {
    case normalNote = 0
    case white
    case sand
    case watermelon
    case powderBlue
    case mint
    
    func pairColor() -> (light: UIColor, dark: UIColor) {
        switch self {
        case .sand:
            return (UIColor(red:0.94, green:0.87, blue:0.71, alpha:1.00),
                    UIColor(red:0.83, green:0.76, blue:0.59, alpha:1.00))
        case .white:
            return (UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00),
                    UIColor(red:0.74, green:0.76, blue:0.78, alpha:1.00))
        case .normalNote:
            return (UIColor(red:0.99, green:0.99, blue:0.80, alpha:1.00),
                    UIColor(red:0.95, green:0.93, blue:0.65, alpha:1.00))
        case .watermelon:
            return (UIColor(red:0.93, green:0.45, blue:0.49, alpha:1.00),
                    UIColor(red:0.84, green:0.33, blue:0.36, alpha:1.00))
        case .powderBlue:
            return (UIColor(red:0.73, green:0.79, blue:0.94, alpha:1.00),
                    UIColor(red:0.60, green:0.67, blue:0.83, alpha:1.00))
        case .mint:
            return (UIColor(red:0.16, green:0.73, blue:0.61, alpha:1.00),
                    UIColor(red:0.14, green:0.62, blue:0.52, alpha:1.00))
        }
        
    }
}

extension UIColor {
    func bgColor(to: UIView) {
        to.backgroundColor = self
    }
    
    func toImage(size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(self.cgColor)
        context?.fill(CGRect(x:0, y:0, width: size.width, height: size.height))
        
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return output!
    }
}

extension UIView {
    func bgClear() {
        self.backgroundColor = UIColor.clear
    }
    
    func addCardShadow() {
        self.layer.cornerRadius = 2
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 2
        self.layer.shadowOffset = CGSize(width: 1, height: 3)
    }
    
    func addFullSideShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 10
        self.layer.shadowOffset = CGSize.zero
//        self.layer.shadowPath = CGPath(rect: self.layer.bounds, transform: nil)
        
        
    }
}
