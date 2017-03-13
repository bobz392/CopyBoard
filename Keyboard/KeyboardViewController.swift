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
    fileprivate let numberTexts = ["1", "2", "3", "4", "5", "6", "7", "8", "9", ",", "0", "."]
    
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
        
        self.keyboardView.configNumberCollectionViewLayout()
        self.updateViewConstraints()
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let heightConstraint = NSLayoutConstraint(item: self.view, attribute: .height, relatedBy: .equal, toItem: nil,
                                                  attribute: .notAnAttribute, multiplier: 0, constant: DKManager.shared.keyboardHeight + kBottomKeyboardToolViewHeight + 0.5)
        self.view.addConstraint(heightConstraint)
        
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
        
        if #available(iOSApplicationExtension 10.0, *) {
            self.keyboardView.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
            
        } else {
            self.keyboardView.nextKeyboardButton.addTarget(self, action: #selector(self.advanceToNextInputMode), for: .allTouchEvents)
        }
        
        self.keyboardView.launchAppButton.addTarget(self, action: #selector(self.launchAppAction), for: .touchUpInside)
        self.keyboardView.deleteButton.addTarget(self, action: #selector(self.deleteTextAction(btn:)), for: .touchUpInside)
        self.keyboardView.returnButton.addTarget(self, action: #selector(self.returnAction), for: .touchUpInside)
        self.keyboardView.numberButton.addTarget(self, action: #selector(self.numberAction), for: .touchUpInside)
        self.keyboardView.spaceButton.addTarget(self, action: #selector(self.spaceAction), for: .touchUpInside)
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
    }
    
    func numberAction() {
        self.keyboardView.showNumber = !self.keyboardView.showNumber
        if self.keyboardView.showNumber {
            self.keyboardView.numberButton.setImage(Icons.text.iconImage(), for: .normal)
        } else {
            self.keyboardView.numberButton.setImage(Icons.number.iconImage(), for: .normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
        Logger.log("text will change = \(textInput)")
        Logger.log(self.textDocumentProxy.documentContextBeforeInput ?? "before input = nil")
        Logger.log(self.textDocumentProxy.documentContextAfterInput ?? "after input = nil")
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        Logger.log("text did change = \(textInput)")
        
        
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
        if collectionView == self.keyboardView.collectionView {
            if let notes = self.notes {
                return notes.count
            } else {
                return self.defaultNotes.count
            }
        } else {
            return 12
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.keyboardView.collectionView {
            if let content = self.notes?[indexPath.row].content {
                self.textDocumentProxy.insertText(content)
            } else {
                self.textDocumentProxy.insertText(self.defaultNotes[indexPath.row])
            }
        } else {
            self.textDocumentProxy.insertText(self.numberTexts[indexPath.row])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CollectionCellHighlight {
            cell.highlight()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CollectionCellHighlight {
            cell.unhighlight()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.keyboardView.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KeyboardCollectionViewCell.reuseId, for: indexPath) as! KeyboardCollectionViewCell
            
            if let note = self.notes?[indexPath.row] {
                cell.noteLabel.text = note.content
                cell.backgroundColor = AppPairColors(rawValue: note.color)?.pairColor().light
            } else {
                cell.noteLabel.text = self.defaultNotes[indexPath.row]
                cell.backgroundColor = AppPairColors(rawValue: 0)?.pairColor().light
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NumberCollectionViewCell.reuseId, for: indexPath) as! NumberCollectionViewCell
            cell.numberLabel.text = self.numberTexts[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAt indexPath: IndexPath!) -> CGSize {
        if let layout = collectionView.collectionViewLayout as? CHTCollectionViewWaterfallLayout {
            if collectionView == self.keyboardView.collectionView {
                let font = appFont(size: 16)
                let space = CGFloat(layout.columnCount + 1) * DKManager.shared.itemSpace
                let width = (self.view.frame.width - space) / CGFloat(layout.columnCount)
                let lineCount = self.notes == nil ? 3 : AppSettings.shared.realKeyboardLine(line: nil, inKeyboardExtension: true)
                let height = ceil(font.lineHeight * CGFloat(lineCount)) + 10
                
                return CGSize(width: width, height: height)
            } else {
                return self.keyboardView.numberCollectionItemSize()
            }
        } else {
            return .zero
        }
    }
    
}
