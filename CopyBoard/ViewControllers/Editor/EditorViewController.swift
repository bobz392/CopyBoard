//
//  EditorViewController.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/20.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EditorViewController: BaseViewController {
    
    let editorView = EditorView()
    
    fileprivate let note: Note
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate var currentPairColor: [AppPairColors]? = nil
    
    fileprivate var noteChanged = false
    fileprivate let isCreate: Bool
    
    init(note: Note) {
        self.note = note
        self.isCreate = false
        super.init(nibName: nil, bundle: nil)
    }
    
    init(defaultContent: String? = nil) {
        self.note = Note()
        self.note.noteCreator(content: defaultContent ?? "  ", createdAt: Date())
        self.note.color = 0
        self.isCreate = true
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let weakSelf = self
        self.editorView.config(with: self.view,note: note) {
            weakSelf.dismiss(animated: true, completion: { (finish) -> Void in })
            weakSelf.updateNoteIfNeed()
        }
        
        self.editorView.editorTextView.delegate = self
        self.editorView.faveButton.rx.tap.subscribe { (event) in
            if weakSelf.isCreate {
                weakSelf.note.favourite = !weakSelf.note.favourite
            } else {
                DBManager.shared.updateNote(note: weakSelf.note, updateBlock: {
                    weakSelf.note.favourite = !weakSelf.note.favourite
                })
            }
            }.addDisposableTo(self.disposeBag)
        
        self.editorView.colorButton.rx.tap.subscribe { (event) in
            weakSelf.editorView.changeColor(start: true)
            }.addDisposableTo(self.disposeBag)
        
        self.editorView.closeButton.rx.tap.subscribe { (event) in
            weakSelf.dismissAction()
            }.addDisposableTo(self.disposeBag)
        
        self.editorView.infoButton.rx.tap.subscribe { (event) in
            guard let menuVC = SideMenuManager.menuRightNavigationController else { return }
            weakSelf.present(menuVC, animated: true, completion: nil)
            }.addDisposableTo(self.disposeBag)
        
        self.editorView.colorMenu.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.editorView.editorKeyboardHandle(add: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.editorView.editorKeyboardHandle(add: true)
        if (self.editorView.editorTextView.text == " ") {
            self.editorView.editorTextView.text = ""
        }
    }
    
    func dismissAction() {
        UIView.animate(withDuration: kNoteViewAlphaAnimation, animations: {
            self.editorView.editorTextView.alpha = 0
        }) { (finish) in
            self.editorView.editorTextView.dg_removePullToRefresh()
            self.dismiss(animated: true, completion: nil)
        }
        
        self.updateNoteIfNeed()
    }
    
    private func updateNoteIfNeed() {
        if let noteText = self.editorView.editorTextView.text,
            noteText.characters.count > 0, self.noteChanged {
            
            if self.isCreate {
                self.note.content = noteText
                DBManager.shared.writeNote(note: self.note)
            } else {
                DBManager.shared.updateNote(note: self.note, updateBlock: { [unowned self] in
                    self.note.modificationDevice = DeviceManager.shared.deviceName
                    self.note.modificationDate = Date()
                    self.note.content = noteText
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        self.editorView.editorTextView.dg_removePullToRefresh()
    }
    
    override func deviceOrientationChanged() {
        self.editorView.invalidateLayout()
        SideMenuManager.menuRightNavigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - text view delegate
extension EditorViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.noteChanged = true
        return true
    }
    
    
    func textViewDidChangeSelection(_ textView: UITextView) {
//        if textView.text.characters.count == 0 {
//            self.editorView.configEditorContent(text: text)
//            return false
//        }
        Logger.log("change selection")
    }
}

// MARK: - circle menu delegate
extension EditorViewController: CircleMenuDelegate {
    
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        
        let pairColors: [AppPairColors]
        if let pairs = self.currentPairColor {
            pairColors = pairs
        } else {
            guard let pair = AppPairColors(rawValue: self.note.color) else {
                fatalError("have no this type color \(note.color)")
            }
            pairColors = pair.colorsExceptMe()
            self.currentPairColor = pairColors
        }
        
        button.backgroundColor = pairColors[atIndex].pairColor().dark
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int) {
        if let pc = self.currentPairColor?[atIndex] {
            let weakSelf = self
            weakSelf.editorView.changeColor(pair: pc)
            weakSelf.view.backgroundColor = pc.pairColor().light
            if !self.isCreate {
                DBManager.shared.updateNote(note: weakSelf.note, updateBlock: {
                    weakSelf.note.color = pc.rawValue
                })
            } else {
                weakSelf.note.color = pc.rawValue
            }
            weakSelf.currentPairColor = nil
        }
    }
    
    func menuCollapsed(_ circleMenu: CircleMenu) {
        self.editorView.changeColor(start: false)
    }
    
}
