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

class EditorViewController: UIViewController {

    let editorView = EditorView()
    fileprivate let note: Note
    fileprivate let disposeBag = DisposeBag()

    fileprivate var currentPairColor: [AppPairColors]? = nil
    
    init(note: Note) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let weakSelf = self
        self.editorView.config(with: self.view, note: note) {
            weakSelf.dismiss(animated: true, completion: { (finish) -> Void in
                weakSelf.editorView.editorTextView.dg_removePullToRefresh()
            })
        }

        self.editorView.faveButton.rx.tap.subscribe { (event) in
                    DBManager.shared.updateObject {
                        weakSelf.note.favourite = !weakSelf.note.favourite
                    }
                }.addDisposableTo(self.disposeBag)

        self.editorView.colorButton.rx.tap.subscribe { (event) in
                weakSelf.editorView.changeColor(start: true)
                }.addDisposableTo(self.disposeBag)

        self.editorView.closeButton.rx.tap.subscribe { (event) in
            self.dismissAction()
        }.addDisposableTo(self.disposeBag)

        self.editorView.colorMenu.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.editorView.editorTextView.heroID = nil
        self.editorView.editorTextView.heroModifiers = nil
    }

    func dismissAction() {
        UIView.animate(withDuration: kNoteViewAlphaAnimation, animations: {
            self.editorView.editorTextView.alpha = 0
        }) { (finish) in
            self.editorView.editorTextView.dg_removePullToRefresh()
            self.dismiss(animated: true, completion: nil)
        }
//        if self.editorView.editorTextView.text.characters.count > 0 {
//            DBManager.shared.updateObject {
//                self.note.content = self.editorView.editorTextView.text
//            }
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

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
            DBManager.shared.updateObject(false, updateBlock: { 
                weakSelf.note.color = pc.rawValue
            })
            weakSelf.currentPairColor = nil
        }
    }
    
    func menuCollapsed(_ circleMenu: CircleMenu) {
        self.editorView.changeColor(start: false)
    }
}
