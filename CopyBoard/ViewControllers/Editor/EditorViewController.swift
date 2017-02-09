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
    
    weak var deckVC: IIViewDeckController? = nil
    
    init(note: Note) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createDeckVC() -> IIViewDeckController {
        let menuVC = MenuViewController()
        menuVC.note = self.note
        menuVC.statysBarHidden = DeviceManager.shared.isLandscape
        let deckVC = IIViewDeckController(center: self, rightViewController: menuVC)
        deckVC.view.backgroundColor = AppColors.cloud
        deckVC.delegate = self
        self.deckVC = deckVC
        return deckVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let weakSelf = self
        self.editorView.config(with: self.view, note: note) {
            weakSelf.dismiss(animated: true, completion: { (finish) -> Void in })
            weakSelf.updateNoteIfNeed()
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
            weakSelf.dismissAction()
        }.addDisposableTo(self.disposeBag)

        self.editorView.infoButton.rx.tap.subscribe { (event) in
            if let deckVC = weakSelf.deckVC {
                weakSelf.openMenu(viewDeckController: deckVC)
                deckVC.open(.right, animated: true)
            }
        }.addDisposableTo(self.disposeBag)
        
        self.editorView.colorMenu.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
            
            DBManager.shared.updateObject {
                self.note.modificationDevice = DeviceManager.shared.deviceName
                self.note.modificationDate = Date()
                self.note.content = self.editorView.editorTextView.text
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        self.editorView.editorTextView.dg_removePullToRefresh()
    }
}

// MARK: orientation
extension EditorViewController {
   
    override func deviceOrientationChanged() {
        self.editorView.invalidateLayout()
    }
    
}

// MARK: - text view delegate
extension EditorViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.noteChanged = true
        return true
    }
    
}

// MARK: - view deck controller delegate
extension EditorViewController: IIViewDeckControllerDelegate {
    
    func viewDeckController(_ viewDeckController: IIViewDeckController, willOpen side: IIViewDeckSide) -> Bool {
        if self.editorView.canOpenMenu {
        self.openMenu(viewDeckController: viewDeckController)
        return true
        } else {
            return false
        }
    }
    
    fileprivate func openMenu(viewDeckController: IIViewDeckController) {
        DeviceManager.shared.hiddenStatusBar(hidden: true)
    }
    
    func viewDeckController(_ viewDeckController: IIViewDeckController, didClose side: IIViewDeckSide) {
        DeviceManager.shared.hiddenStatusBar(hidden: false)
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
            DBManager.shared.updateObject(true, updateBlock: {
                weakSelf.note.color = pc.rawValue
            })
            weakSelf.currentPairColor = nil
        }
    }
    
    func menuCollapsed(_ circleMenu: CircleMenu) {
        self.editorView.changeColor(start: false)
    }
    
}
