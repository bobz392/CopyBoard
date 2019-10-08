//
//  ShareViewController.swift
//  StickerShare
//
//  Created by zhoubo on 2017/3/5.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Localized("sticker")
        self.view.backgroundColor = AppColors.mainBackground
        self.navigationController?.view.backgroundColor = AppColors.mainBackground
        self.navigationController?.navigationBar.tintColor = AppColors.mainIcon
        self.navigationController?.navigationBar.barTintColor = AppColors.mainBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let provider = extensionItem.attachments?.first as? NSItemProvider,
            let dataType = provider.registeredTypeIdentifiers.first as? String else {
                return self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
        
        provider.loadItem(forTypeIdentifier: dataType, options: nil, completionHandler: { (text, error) in
            debugPrint("================")
            if let text = text {
                debugPrint("item type \(dataType), text = \(text)")
            }
            debugPrint("================")
            
            if dataType == String(kUTTypeURL) {
                if let u = text as? URL {
                    DispatchQueue.main.async { [unowned self] in
                        self.textView.text = u.absoluteString
                    }
                }
            }
        })
    }
    
    override func isContentValid() -> Bool {
        return self.textView.text.count > 0
    }
    
    override func didSelectPost() {
        self.children.first?.view.backgroundColor = AppColors.mainBackground
        if let content = self.textView.text,
            let first = self.children.first,
            let window = self.view.window,
            let finishView = FinishView.loadNib(self) {
            first.removeFromParent()
            
            DispatchQueue.main.async {
                DBManager.configDB()
                let note = Note()
                note.content = content
                note.createdAt = Date()
                note.modificationDate = note.createdAt
                note.modificationDevice = UIDevice.current.name
                note.uuid = UUIDGenerator.getUUID()
                DBManager.shared.writeObject(note)
                
                finishView.addToWindow(window: window, finishBlock: {  [unowned self] in
                    self.extensionContext!.cancelRequest(withError: NSError() as Error)
                })
            }
         
        } else {
            self.extensionContext!.cancelRequest(withError: NSError() as Error)
        }
        
    }
    
    override func configurationItems() -> [Any]! {
        if let item = SLComposeSheetConfigurationItem(),
            let t = self.textView.text {
            item.title = Localized("segmentation")
            item.tapHandler = { () -> Void in
                let vc = SegmentationViewController(content: t, saveBlock: { [unowned self] (text) in
                    if let t = text {
                        self.textView.text = t
                    }
                    
                    self.popConfigurationViewController()
                })
                vc.title = Localized("segmentation")
                vc.preferredContentSize = self.preferredContentSize
                self.pushConfigurationViewController(vc)
            }
            return [item]
        } else {
            return []
        }
    }
    
}
