//
//  ActionViewController.swift
//  Action
//
//  Created by zhoubo on 2017/3/5.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
//        self.label.textColor = AppColors.faveButton
        
        //        DBManager.configDB()
        
        guard let items = self.extensionContext!.inputItems as? [NSExtensionItem] else {
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }
        self.preferredContentSize = CGSize(width: self.view.frame.width, height: 40)
        print(items)
        for item in items {
            for provider in item.attachments! as! [NSItemProvider] {
                let identifier = kUTTypeText as String
                if provider.hasItemConformingToTypeIdentifier(identifier) {
                    provider.loadItem(forTypeIdentifier: identifier, options: nil, completionHandler: { [unowned self] (text, error) in
                        if let t = text as? String,
                            t.characters.count > 0 {
                            self.label.text = t
                        } else {
                            self.label.text = "no fucking"
                        }
                    })
                }
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
    
}
