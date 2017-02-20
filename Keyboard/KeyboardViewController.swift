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

    @IBOutlet var nextKeyboardButton: UIButton!
    var notes: Results<Note>? = nil
    let keyboardView = KeyboardView()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 10)
//
        self.nextKeyboardButton = UIButton(type: .system)

        DBManager.configDB()
        if DBManager.checkKeyboardAccess() {
            self.keyboardView.config(view: self.view)
            label.text = (DBManager.shared.realm?.configuration.fileURL?.absoluteString)! + "\n" + "\(AppSettings.shared.keyboardLines) "
                //+ "count = \(DBManager.shared.queryNotes())" + "\n"
            self.notes = DBManager.shared.queryNotes()
            
            self.keyboardView.collectionView.delegate = self
            self.keyboardView.collectionView.dataSource = self
            self.keyboardView.collectionView.reloadData()
        } else {
            Logger.log("cant access")
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
//        self.extensionContext?.open(URL(string: UIApplicationOpenSettingsURLString)!, completionHandler: { (finish) in
//            Logger.log("complete")
//        })
//        return
        
        if let url = URL(string: UIApplicationOpenSettingsURLString) {//"prefs:root=General&path=Keyboard") {
            UIApplication.mSharedApplication().mOpenURL(url: url)
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

extension KeyboardViewController: UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.notes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
        debugPrint(space)
        debugPrint(layout.columnCount)
        let width = (self.view.frame.width - space) / CGFloat(layout.columnCount)
        let height = ceil(font.lineHeight * CGFloat(AppSettings.shared.realKeyboardLine())) + 10
        return CGSize(width: width, height: height)
    }
}
