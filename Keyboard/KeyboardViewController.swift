//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by zhoubo on 2017/1/12.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift

class KeyboardViewController: UIInputViewController {

    var notes: Results<Note>? = nil
    let keyboardView = KeyboardView()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
        
    }
    
    override func viewWillLayoutSubviews() {
        if DBManager.canFullAccess() {
            self.keyboardView.collectionView.snp.updateConstraints { maker in
                maker.height.equalTo(DKManager.shared.keyboardHeight)
            }
        } else {
        
        }
        
        self.updateViewConstraints()
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        AppSettings.shared.reload()
        
        if DBManager.canFullAccess() {
            DBManager.configDB()
            self.keyboardView.config(view: self.view)
            self.view.setNeedsUpdateConstraints()
            self.notes = DBManager.shared.keyboardQueryNotes()
            
            self.keyboardView.collectionView.delegate = self
            self.keyboardView.collectionView.dataSource = self
            self.keyboardView.collectionView.reloadData()
        } else {
            Logger.log("cant access")
        }
        
        
//        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
//        self.nextKeyboardButton.sizeToFit()
//        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOSApplicationExtension 10.0, *) {
            self.keyboardView.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
            
        } else {
            self.keyboardView.nextKeyboardButton.addTarget(self, action: #selector(self.advanceToNextInputMode), for: .allTouchEvents)
        }
        
//        self.keyboardView.numberButton.addTarget(self, action: #selector(self.goSettingsAtion), for: .touchUpInside)
        self.keyboardView.launchAppButton.addTarget(self, action: #selector(self.launchAppAction), for: .touchUpInside)
        self.keyboardView.deleteButton.addTarget(self, action: #selector(self.deleteTextAction(btn:)), for: .touchUpInside)
        self.keyboardView.returnButton.addTarget(self, action: #selector(self.returnAction), for: .touchUpInside)
        self.keyboardView.spaceButton.addTarget(self, action: #selector(self.spaceAction), for: .touchUpInside)
        self.keyboardView.previewButton.addTarget(self, action: #selector(self.previewAction(btn:)), for: .touchUpInside)
        
        print(self.textDocumentProxy.keyboardType?.rawValue ?? "hahaha not type")
    }
    

    
    func goSettingsAtion() {
        if #available(iOSApplicationExtension 10.0, *) {
            if let url = URL(string: "App-Prefs:root=General&path=Keyboard/KEYBOARDS") {
                UIApplication.mSharedApplication().mOpenURL(url: url)
            }
        } else {
            if let url = URL(string: "prefs:root=General&path=Keyboard/KEYBOARDS") {
                UIApplication.mSharedApplication().mOpenURL(url: url)
            }
        }
    }
    
    func launchAppAction() {
        if let url = URL(string: "sticker://") {
            UIApplication.mSharedApplication().mOpenURL(url: url)
        }
    }
    
    func deleteTextAction(btn: UIButton) {
        self.textDocumentProxy.deleteBackward()
    }
    
    func returnAction() {
        self.textDocumentProxy.insertText("\n")
    }
    
    func previewAction(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        btn.backgroundColor = btn.isSelected ? UIColor.white : AppColors.keyboard
    }
    
    func spaceAction() {
        self.textDocumentProxy.insertText(" ")
        
//        CFStringTokenizer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
        print("text will change = \(textInput)")
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        print("text did change = \(textInput)")
//        var textColor: UIColor
//        let proxy = self.textDocumentProxy
//        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
//            textColor = UIColor.white
//        } else {
//            textColor = UIColor.black
//        }
//        self.keyboardView.nextKeyboardButton.setTitleColor(textColor, for: [])
    }

}

extension KeyboardViewController: UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.notes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let content = self.notes?[indexPath.row].content {
            self.textDocumentProxy.insertText(content)
        }
        
        print(self.view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KeyboardCollectionViewCell.reuseId, for: indexPath) as! KeyboardCollectionViewCell
        if let note = self.notes?[indexPath.row] {
            cell.noteLabel.text = note.content
            cell.backgroundColor = AppPairColors(rawValue: note.color)?.pairColor().light
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAt indexPath: IndexPath!) -> CGSize {
        let layout = collectionView.collectionViewLayout as! CHTCollectionViewWaterfallLayout
        
        let font = UIFont.systemFont(ofSize: 16)
        let space = CGFloat(layout.columnCount + 1) * DKManager.shared.itemSpace
        let width = (self.view.frame.width - space) / CGFloat(layout.columnCount)
        let lineCount = AppSettings.shared.realKeyboardLine(line: nil, inKeyboard: true)
        let height = ceil(font.lineHeight * CGFloat(lineCount)) + 10
//        print("line height = \(AppSettings.shared.realKeyboardLine(line: nil, inKeyboard: true)"))
        print("line count = \(lineCount)")
        return CGSize(width: width, height: height)
    }
}
