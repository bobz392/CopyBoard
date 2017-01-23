//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by zhoubo on 2017/1/12.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit
import SnapKit

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 10)
        
        self.nextKeyboardButton = UIButton(type: .system)
        
        DBManager.configDB()
        
        if DBManager.checkKeyboardAccess() {
            Logger.log(DBManager.shared.queryNotes())
            label.text = (DBManager.shared.realm.configuration.fileURL?.absoluteString)! + "\n"
                + "count = \(DBManager.shared.queryNotes())"

        } else {
            label.text = "cant access"
        }
        
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOSApplicationExtension 10.0, *) {
            self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        } else {
            self.nextKeyboardButton.addTarget(self, action: #selector(self.advanceToNextInputMode), for: .allTouchEvents)
        }
        
        
        
        let settingButton = UIButton(type: UIButtonType.system)
        settingButton.addTarget(self, action: #selector(self.open), for: .touchUpInside)
        settingButton.setTitle("go", for: .normal)
        self.view.addSubview(settingButton)
        settingButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        self.view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(settingButton.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        self.view.addSubview(self.nextKeyboardButton)
        
        if #available(iOSApplicationExtension 9.0, *) {
            self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
        if #available(iOSApplicationExtension 9.0, *) {
            self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    func open() {
        if let url = URL(string: UIApplicationOpenSettingsURLString) {//"prefs:root=General&path=Keyboard") {
//            self.extensionContext?.open(url, completionHandler: { (finish) in
//                
//            })
            UIApplication.🚀sharedApplication().🚀openURL(url: url)
        } else {
            Logger.log("go url = nil")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }

}

extension UIApplication {
    
    public static func 🚀sharedApplication() -> UIApplication {
        
        guard UIApplication.responds(to: Selector("sharedApplication")) else {
            fatalError("UIApplication.sharedKeyboardApplication(): `UIApplication` does not respond to selector `sharedApplication`.")
        }
        
        
        guard let unmanagedSharedApplication = UIApplication.perform(Selector("sharedApplication")) else {
            fatalError("UIApplication.sharedKeyboardApplication(): `UIApplication.sharedApplication()` returned `nil`.")
        }
        
        guard let sharedApplication = unmanagedSharedApplication.takeUnretainedValue() as? UIApplication else {
            fatalError("UIApplication.sharedKeyboardApplication(): `UIApplication.sharedApplication()` returned not `UIApplication` instance.")
        }
        
        return sharedApplication
    }
    
    public func 🚀openURL(url: URL) {
        self.performSelector(onMainThread: Selector("openURL:"), with: url, waitUntilDone: true)
    }
    
}
