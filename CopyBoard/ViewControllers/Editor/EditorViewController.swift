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

                }.addDisposableTo(self.disposeBag)

        self.editorView.closeButton.rx.tap.subscribe { (event) in
            self.dismissAction()
        }.addDisposableTo(self.disposeBag)

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

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
