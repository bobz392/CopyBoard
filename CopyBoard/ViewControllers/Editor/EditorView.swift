//
//  EditorView.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/20.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit
import SnapKit

class EditorView {
    let editorTextView = UITextView()
    let barView = UIView()
    let realBarView = BarView()
    let keyboardBarView = UIView()
    
    let closeButton = TouchButton(type: .custom)
    let infoButton = TouchButton(type: .custom)
    let colorButton = TouchButton(type: .custom)
    let colorHolderView = UIView()
    
    let colorMenu = CircleMenu(frame: .zero, normalIcon: nil, selectedIcon: Icons.bigClear.iconString())
    let faveButton = FaveButton(frame: CGRect(origin: .zero, size: CGSize(width: 34, height: 34)), faveIconNormal: Icons.star.iconImage())
    
    var menuGesture: UIScreenEdgePanGestureRecognizer? = nil
    
    func config(with view: UIView, note: Note, dismissBlock: @escaping () -> Void) {
        self.configBarView(view: view)
        self.configNote(view: view, content: note.content)
        self.configColorView(view: view)
        
        let weakSelf = self
        let loadingView = PullDismissView { (progress) in
            weakSelf.faveButton.alpha = 1 - progress
            weakSelf.colorButton.alpha = 1 - progress
            weakSelf.closeButton.alpha = 1 - progress
            weakSelf.infoButton.alpha = 1 - progress
        }
        
        self.editorTextView.dg_addPullToRefreshWithActionHandler({ () -> Void in
            dismissBlock()
        }, loadingView: loadingView)
        
        if let pairColor = AppPairColors(rawValue: note.color)?.pairColor() {
            self.editorTextView.dg_setPullToRefreshFillColor(pairColor.dark)
            self.editorTextView.dg_setPullToRefreshBackgroundColor(pairColor.light)
            self.barView.backgroundColor = pairColor.dark
            view.backgroundColor = pairColor.light
            self.keyboardBarView.backgroundColor = pairColor.dark
        }
        
        self.faveButton.isSelected = note.favourite
        
        self.configKeyboardAction(view: view)
        self.configMenu(view: view, note: note)
    }
    
    fileprivate func configMenu(view: UIView, note: Note) {
        let menuVC = MenuViewController()
        menuVC.note = note
        
        let rightMenu = UISideMenuNavigationController(rootViewController: menuVC)
        SideMenuManager.menuRightNavigationController = rightMenu
        self.menuGesture = SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: view, forMenu: .right).first
        SideMenuManager.menuPresentMode = .menuSlideIn
        SideMenuManager.menuFadeStatusBar = false
        SideMenuManager.menuShadowOpacity = 0
        SideMenuManager.menuShadowRadius = 0
        SideMenuManager.menuAnimationFadeStrength = 0.6
    }
    
    func changeColor(start: Bool) {
        let weakSelf = self
        self.editorTextView.resignFirstResponder()
        if start {
            self.colorHolderView.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                weakSelf.colorHolderView.alpha = 1
            }, completion: { (finish) in
                weakSelf.colorMenu.onTap()
            })
            
            
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                weakSelf.colorHolderView.alpha = 0
            }, completion: { (finish) in
                weakSelf.colorHolderView.isHidden = true
            })
            
        }
    }
    
    func changeColor(pair: AppPairColors) {
        let weakSelf = self
        let pc = pair.pairColor()
        UIView.animate(withDuration: 0.4, animations: {
            weakSelf.barView.backgroundColor = pc.dark
            weakSelf.editorTextView.backgroundColor = pc.light
            weakSelf.editorTextView.dg_setPullToRefreshFillColor(pc.dark)
            weakSelf.editorTextView.dg_setPullToRefreshBackgroundColor(pc.light)
            weakSelf.barView.backgroundColor = pc.dark
        }, completion: { (finish) in
            weakSelf.changeColor(start: false)
        })
    }
    
    @objc func dismissKeyboard() {
        self.editorTextView.resignFirstResponder()
    }
    
    fileprivate func configKeyboardAction(view: UIView) {
        view.addSubview(self.keyboardBarView)
        self.keyboardBarView.snp.makeConstraints { maker in
            maker.height.equalTo(38)
            maker.width.equalTo(38)
            maker.bottom.equalTo(self.editorTextView)
            maker.right.equalToSuperview()
        }
        self.keyboardBarView.alpha = 0
        
        let hideKeyboardButton = TouchButton(type: .system)
        hideKeyboardButton.setImage(Icons.hideKeyboard.iconImage(), for: .normal)
        hideKeyboardButton.config()
        hideKeyboardButton.addTarget(self, action: #selector(self.dismissKeyboard), for: .allEvents)
        self.keyboardBarView.addSubview(hideKeyboardButton)
        hideKeyboardButton.snp.makeConstraints { maker in
            maker.width.equalTo(32)
            maker.height.equalTo(32)
            maker.center.equalToSuperview()
        }
    }
    
    func editorKeyboardHandle(add: Bool) {
        if add {
            let weakSelf = self
            KeyboardManager.shared.setHander { (show, height, duration) in
                let statusBarHeight = DeviceManager.shared.statusbarHeight
                let navigationBarHeight = DeviceManager.shared.navigationBarHeight
                let barHeight: CGFloat = show ?
                    statusBarHeight : (statusBarHeight + navigationBarHeight)
                let textViewBottom: CGFloat = show ? -height : 0
                let barViewAlpha: CGFloat = show ? 0 : 1
                
                weakSelf.menuGesture?.isEnabled = !show
                Logger.log("menu enable = \(!show)")
                weakSelf.barView.snp.updateConstraints({ maker in
                    maker.height.equalTo(barHeight)
                })
                weakSelf.editorTextView.snp.updateConstraints({ maker in
                    maker.bottom.equalToSuperview().offset(textViewBottom)
                })
                
                UIView.animate(withDuration: duration, animations: {
                    weakSelf.barView.superview?.layoutIfNeeded()
                    weakSelf.realBarView.alpha = barViewAlpha
                    weakSelf.keyboardBarView.alpha = 1 - barViewAlpha
                })
            }
        } else {
            KeyboardManager.shared.removeHander()
        }
    }
    
    fileprivate func configBarView(view: UIView) {
        view.addSubview(self.barView)
        let statusBarHeight = DeviceManager.shared.statusbarHeight
        let navigationBarHeight = DeviceManager.shared.navigationBarHeight
        self.barView.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.height.equalTo(statusBarHeight + navigationBarHeight)
        }

        self.barView.addSubview(self.realBarView)
        self.realBarView.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(statusBarHeight)
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
        self.realBarView.bgClear()
        
        self.realBarView.appendButtons(buttons: [closeButton], left: true)
        self.closeButton.setImage(Icons.bigClear.iconImage(), for: .normal)
        self.closeButton.config()

        self.realBarView.appendButtons(buttons: [faveButton, colorButton, infoButton], left: false)
        self.infoButton.setImage(Icons.info.iconImage(), for: .normal)
        self.colorButton.setImage(Icons.color.iconImage(), for: .normal)
        self.infoButton.config()
        self.colorButton.config()
        
        self.faveButton.normalColor = UIColor.white
        self.faveButton.selectedColor = AppColors.faveButton
        self.faveButton.dotFirstColor = UIColor(red:0.99, green:0.65, blue:0.17, alpha:1.00)
        self.faveButton.dotSecondColor = UIColor(red:0.98, green:0.41, blue:0.22, alpha:1.00)
    }

    fileprivate func configColorView(view: UIView) {
        self.colorHolderView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        self.colorHolderView.alpha = 0
        self.colorHolderView.isHidden = true
        
        view.addSubview(self.colorHolderView)
        self.colorHolderView.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
        }
        
        self.colorHolderView.addSubview(self.colorMenu)
        self.colorMenu.backgroundColor = UIColor.white
        self.colorMenu.buttonsCount = 5
        self.colorMenu.duration = 0.5
        self.colorMenu.distance = 120
        self.colorMenu.snp.makeConstraints { maker in
            maker.height.equalTo(60)
            maker.width.equalTo(60)
            maker.center.equalToSuperview()
        }
        self.colorMenu.layer.cornerRadius = 30
    }
    
    fileprivate func configNote(view: UIView, content: String) {
        view.addSubview(editorTextView)
//        self.editorTextView.spliteLineColor = AppColors.horizonLine
//        self.editorTextView.font = self.editorTextView.noteFont
        self.editorTextView.bgClear()
        self.editorTextView.textColor = AppColors.noteText
        self.editorTextView.tintColor = AppColors.noteText
        self.editorTextView.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12)
        self.editorTextView.alwaysBounceVertical = true
        self.editorTextView.dataDetectorTypes = .all

        self.editorTextView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalTo(self.barView.snp.bottom)
            maker.bottom.equalToSuperview()
        }

        let attrString = NSMutableAttributedString(string: content)
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = NoteTextView.NoteLineSpace
        
        attrString.addAttributes([
            NSParagraphStyleAttributeName: paraStyle,
            NSFontAttributeName: appFont(size: 18),
            NSForegroundColorAttributeName: AppColors.noteText
            ], range: NSMakeRange(0, content.characters.count))
        self.editorTextView.attributedText = attrString
    }
    
    func invalidateLayout() {
        let statusBarHeight = DeviceManager.shared.statusbarHeight
        let navigationBarHeight = DeviceManager.shared.navigationBarHeight
        self.barView.snp.updateConstraints { maker in
            maker.height.equalTo(navigationBarHeight + statusBarHeight)
        }
        
        self.realBarView.snp.updateConstraints { maker in
            maker.top.equalToSuperview().offset(statusBarHeight)
        }

        self.barView.superview?.layoutIfNeeded()
    }

}
