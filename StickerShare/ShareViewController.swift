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
        
        let titleLabel =
            UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 30)))
        titleLabel.text = Localized("sticker")
        titleLabel.font = appFont(size: 17)
        titleLabel.textColor = AppColors.mainIcon
        titleLabel.textAlignment = .center
        
        self.navigationItem.titleView = titleLabel
        self.view.backgroundColor = AppColors.mainBackground
        self.navigationController?.view.backgroundColor = AppColors.mainBackground
        self.navigationController?.navigationBar.topItem?.titleView = titleLabel
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
            debugPrint("item type \(dataType), text = \(text)")
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
        return self.textView.text.characters.count > 0
    }
    
    override func didSelectPost() {
        self.childViewControllers.first?.view.backgroundColor = AppColors.mainBackground
        if let content = self.textView.text,
            let first = self.childViewControllers.first,
            let window = self.view.window,
            let finishView = FinishView.loadNib(self) {
            first.removeFromParentViewController()
            
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
                    self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
                })
            }
         
        } else {
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
        
    }
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
}
