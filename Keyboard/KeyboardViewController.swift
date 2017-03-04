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
    var defaultNotes = [String]()
    
    let keyboardView = KeyboardView()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
        
    }
    
    override func viewWillLayoutSubviews() {
        self.keyboardView.collectionView.snp.updateConstraints { maker in
            maker.height.equalTo(DKManager.shared.keyboardHeight)
        }
        if let layout = self.keyboardView.collectionView.collectionViewLayout as? CHTCollectionViewWaterfallLayout {
            layout.columnCount = DKManager.shared.columnCount
        }
        self.updateViewConstraints()
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AppSettings.shared.reload()
        self.keyboardView.config(view: self.view)
        
        if DBManager.canFullAccess() {
            DBManager.configDB()
            self.view.setNeedsUpdateConstraints()
            self.notes = DBManager.shared.keyboardQueryNotes()
        } else {
            self.defaultNotes.append(contentsOf: AppSettings.shared.keyboardDefaultNote)
            self.keyboardView.configTopToolView(view: self.view)
            Logger.log("cant access")
        }
        
        self.keyboardView.collectionView.delegate = self
        self.keyboardView.collectionView.dataSource = self
        self.keyboardView.collectionView.reloadData()
        
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
//        self.keyboardView.previewButton.addTarget(self, action: #selector(self.previewAction(btn:)), for: .touchUpInside)
        self.keyboardView.saveButton.addTarget(self, action: #selector(self.saveAction), for: .touchUpInside)
        
        print(self.textDocumentProxy.keyboardType?.rawValue ?? "hahaha not type")
    }
    
    func launchAppAction() {
        if let url = URL(string: "sticker://") {
            UIApplication.mSharedApplication().mOpenURL(url: url)
        }
    }
    
    func saveAction() {
        if self.notes != nil {
            if let text = UIPasteboard.general.string {
                let note = Note()
                note.content = text
                note.createdAt = Date()
                note.modificationDate = note.createdAt
                note.modificationDevice = UIDevice.current.name
                note.uuid = UUIDGenerator.getUUID()
                DBManager.shared.writeObject(note)
                
                self.notes = DBManager.shared.keyboardQueryNotes()
                self.keyboardView.collectionView.reloadData()
                UIPasteboard.general.string = nil
            }
        } else {
            self.keyboardView.topToolViewShine()
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
        if let notes = self.notes {
            return notes.count
        } else {
            return self.defaultNotes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let content = self.notes?[indexPath.row].content {
            self.textDocumentProxy.insertText(content)
        } else {
            self.textDocumentProxy.insertText(self.defaultNotes[indexPath.row])
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KeyboardCollectionViewCell.reuseId, for: indexPath) as! KeyboardCollectionViewCell
        
        if let note = self.notes?[indexPath.row] {
            cell.noteLabel.text = note.content
            cell.backgroundColor = AppPairColors(rawValue: note.color)?.pairColor().light
        } else {
            cell.noteLabel.text = self.defaultNotes[indexPath.row]
            cell.backgroundColor = AppPairColors(rawValue: 0)?.pairColor().light
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAt indexPath: IndexPath!) -> CGSize {
        let layout = collectionView.collectionViewLayout as! CHTCollectionViewWaterfallLayout
        
        let font = appFont(size: 16)
        let space = CGFloat(layout.columnCount + 1) * DKManager.shared.itemSpace
        let width = (self.view.frame.width - space) / CGFloat(layout.columnCount)
        let lineCount = AppSettings.shared.realKeyboardLine(line: nil, inKeyboardExtension: true)
        let height = ceil(font.lineHeight * CGFloat(lineCount)) + 10

        return CGSize(width: width, height: height)
    }
}
