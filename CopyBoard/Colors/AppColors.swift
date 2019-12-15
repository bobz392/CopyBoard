//
//  AppColors.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/18.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

struct AppColors {
    
    static let noteText = UIColor(red:0.17, green:0.24, blue:0.31, alpha:1.00)
    static let noteDate = UIColor(red:0.99, green:0.99, blue:1.00, alpha:1.00)
    static let mainIcon = UIColor(red:0.61, green:0.61, blue:0.61, alpha:1.00)

    static let mainBackground = UIColor(red:0.91, green:0.89, blue:0.85, alpha:1.00)
    static let mainBackgroundAlpha = UIColor(red:0.91, green:0.89, blue:0.85, alpha:0.95)
    static let mainBackgroundAlphaLight = UIColor(red:0.91, green:0.89, blue:0.85, alpha:0.6)
    static let emptyText = UIColor(red:0.77, green:0.76, blue:0.73, alpha:1.00)
    static let searchText = UIColor(red:0.96, green:0.89, blue:0.11, alpha:1.00)
    static let faveButton = UIColor(red:0.99, green:0.67, blue:0.26, alpha:1.00)
    static let cloud = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
    static let cloudHeader = UIColor(red:0.93, green:0.94, blue:0.95, alpha:0.8)
    static let menuText = UIColor(red:0.33, green:0.33, blue:0.33, alpha:1.00)
    static let menuSecondaryText = UIColor(red:0.63, green:0.63, blue:0.63, alpha:1.00)
    
    static let appRed = UIColor(red:0.86, green:0.30, blue:0.32, alpha:1.00)
    
    static let keyboard = UIColor(red:0.67, green:0.70, blue:0.73, alpha:1.0)
    static let keyboardTint = UIColor(red:0.17, green:0.24, blue:0.31, alpha:1.00)
    
    static let cellSelected = UIColor(red:0.99, green:0.99, blue:1.00, alpha:0.4)
    
    static func filterImages() -> [UIImage] {
        let colors = [
            AppPairColors.sand.pairColor().light,
            AppPairColors.pink.pairColor().light,
            AppPairColors.white.pairColor().light,
            AppPairColors.watermelon.pairColor().light,
            AppPairColors.powderBlue.pairColor().light,
            AppPairColors.mint.pairColor().light,
        ]
        let size: CGFloat = 20
        let renderer =
            UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        
        return colors.map { (color) -> UIImage in
            renderer.image { context in
              context.cgContext.setFillColor(color.cgColor)

              let rectangle = CGRect(x: 0, y: 0,
                                     width: size, height: size)
              context.cgContext.addRect(rectangle)
              context.cgContext.drawPath(using: .fill)
            }
        }
    }
}

enum AppPairColors: Int, CustomDebugStringConvertible {
    case sand = 0
    case pink
    case white
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
        case .pink:
            return (UIColor(red:0.81, green:0.58, blue:0.85, alpha:1.00),
                    UIColor(red:0.73, green:0.41, blue:0.78, alpha:1.00))
        case .watermelon:
            return (UIColor(red:0.94, green:0.60, blue:0.60, alpha:1.00),//UIColor(red:0.93, green:0.45, blue:0.49, alpha:1.00),
                    UIColor(red:0.84, green:0.33, blue:0.36, alpha:1.00))
        case .powderBlue:
            return (UIColor(red:0.73, green:0.79, blue:0.94, alpha:1.00),
                    UIColor(red:0.60, green:0.67, blue:0.83, alpha:1.00))
        case .mint:
            return (UIColor(red:0.50, green:0.80, blue:0.77, alpha:1.00),
                    UIColor(red:0.30, green:0.71, blue:0.67, alpha:1.00))
        }
    }
    
    func colorsExceptMe() -> [AppPairColors] {
        let colors: [AppPairColors] = [
            .sand,
            .pink,
            .white,
            .watermelon,
            .powderBlue,
            .mint
        ]
        
        return colors.filter({ (pairColor) -> Bool in
            pairColor != self
        })
    }
    
    var debugDescription: String {
        get {
            switch self {
            case .sand:
                return "sand"
            case .white:
                return "whit"
            case .pink:
                return "pink"
            case .watermelon:
                return "watermelon"
            case .powderBlue:
                return "powderBlue"
            case .mint:
                return "mint"
            }
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
