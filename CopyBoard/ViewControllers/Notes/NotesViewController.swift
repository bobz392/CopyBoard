//
//  ViewController.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/12.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class NotesViewController: BaseViewController {
    
    let noteView = NoteView()
    var viewModel: NotesViewModel!
    fileprivate var selectedCell: NoteCollectionViewCell? = nil
    fileprivate var noteHeight: CGFloat? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let bar = self.navigationController?.navigationBar {
            self.noteView.configBarView(bar: bar)
        }
        self.noteView.config(withView: self.view)
        self.noteView.configCollectionView(view: self.view, delegate: self)
        
        let weakSelf = self
        
        let searchDriver = self.noteView.searchBar.rx.text.orEmpty.asDriver()
        self.viewModel = NotesViewModel(searchDriver: searchDriver, searchBlock: { (query) in
            weakSelf.noteView.searchViewStateChange(query: query.characters.count > 0,
                                                    notesCount: weakSelf.viewModel.notesCount())
        })
        
        DBManager.shared.bindNotifyToken(result: self.viewModel.notes, dataSource: self)
        
        self.noteView.searchButton.rx.tap.subscribe { (tap) in
            weakSelf.noteView.searchAnimation(startSearch: true)
            weakSelf.viewModel.isInSearch = true
            NoteCollectionViewInputOverlay.closeOpenItem()
            }.addDisposableTo(viewModel.disposeBag)
        
        self.noteView.searchBar.rx.cancelButtonClicked.subscribe { (cancel) in
            weakSelf.endSearchAction()
            }.addDisposableTo(viewModel.disposeBag)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.endSearchAction))
        self.noteView.searchHolderView.addGestureRecognizer(tap)
        
        #if debug
            Note.noteTestData()
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(self.noteView.collectionView, delay: 0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        DeviceManager.canRotate = false
        super.viewWillDisappear(animated)
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.stopFollowingScrollView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.selectedCell?.willLeaveEditor()
        self.selectedCell = nil
        
        dispatchDelay(0.25) {
            DeviceManager.canRotate = true
        }
    }
    
    deinit {
        DBManager.shared.unbindNotify()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func endSearchAction() {
        self.noteView.searchAnimation(startSearch: false)
        if !self.viewModel.isQueryStringEmpty {
            self.noteView.collectionView.reloadData()
        }
        self.viewModel.isInSearch = false
        self.viewModel.isQueryStringEmpty = true
    }
    
}

// MARK: - realm notification data source
extension NotesViewController: RealmNotificationDataSource {
    
    func dataInit() {
        self.noteView.collectionView.reloadData()
    }
    
    func update(deletions: [Int], insertions: [Int], modifications: [Int]) {
        if insertions.count > 0 {
            self.noteView.collectionView
                .insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })
        } else if deletions.count > 0 {
            self.noteView.collectionView
                .deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
        } else if modifications.count > 0 {
            self.noteView.collectionView
                .reloadItems(at: modifications.map { IndexPath(row: $0, section: 0) })
        }
    }
    
}

// MARK: transition scroll
extension NotesViewController {
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print("new size \(size)")
    }
    
    override func deviceOrientationChanged() {
        print("deviceOrientationChanged")
        NoteCollectionViewInputOverlay.closeOpenItem()
        self.noteView.invalidateLayout()
    }
    
}

// MARK: collection view
extension NotesViewController: UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.viewModel.notesCount()
        
        if !self.viewModel.isInSearch {
            self.noteView.emptyNotesView(hidden: count > 0)
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath)
            as? NoteCollectionViewCell else { return }
        
        let note = self.viewModel.noteIn(row: indexPath.row)
        let editorVC = EditorViewController(note: note)
        let weakSelf = self
        let row = indexPath.row
        
        let toBlock = { () -> Void in
            weakSelf.noteView.collectionView.heroModifiers =
                [.scale(2), .fade, .duration(kHeroAnimationDuration * 0.8)]
            
            let p = CGPoint(x: weakSelf.noteView.barView.center.x, y: -64)
            weakSelf.noteView.barView.heroModifiers = [.fade, .duration(kHeroAnimationDuration * 0.8), .position(p)]
            
            editorVC.isHeroEnabled = true
            editorVC.editorView.faveButton.heroID = "\(row)star"
            editorVC.editorView.faveButton.heroModifiers = [.duration(kHeroAnimationDuration)]
            
            editorVC.editorView.barView.heroID = "\(row)header"
            editorVC.editorView.barView.heroModifiers = [.duration(kHeroAnimationDuration)]
            
            editorVC.view.heroID = "\(row)card"
            editorVC.view.heroModifiers = [.duration(kHeroAnimationDuration)]
            
            editorVC.editorView.colorButton.heroModifiers =
                [.translate(x: 84, y: 0), .fade, .duration(kHeroAnimationDuration - 0.1), .delay(0.1)]
            editorVC.editorView.closeButton.heroModifiers =
                [.translate(x: -44, y: 0), .fade, .duration(kHeroAnimationDuration - 0.1), .delay(0.1)]
            
            editorVC.editorView.editorTextView.heroID = "\(row)note"
            editorVC.editorView.editorTextView.heroModifiers =
                [.translate(x: 0, y: 70), .fade, .duration(kHeroAnimationDuration - 0.1), .delay(0.1)]
            weakSelf.present(editorVC, animated: true, completion: nil)
        }
        
        cell.willToEditor(block: toBlock, row: row)
        self.selectedCell = cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCollectionViewCell.reuseId, for: indexPath) as! NoteCollectionViewCell
        let note = self.viewModel.noteIn(row: indexPath.row)
        let query = self.noteView.searchBar.text
        cell.configCell(use: note, query: query)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAt indexPath: IndexPath!) -> CGSize {
        let note = self.viewModel.noteIn(row: indexPath.row)
        let layout = collectionView.collectionViewLayout as! CHTCollectionViewWaterfallLayout
        
        let font = appFont(size: 16)
        let space = CGFloat(layout.columnCount + 1) * self.noteView.collectionViewItemSpace()
        let width = (self.view.frame.width - space) / CGFloat(layout.columnCount)
        let height = self.dynamicHeight(content: note.content, font: font, width: width - 10)
        return CGSize(width: width, height: height + 35)
    }
    
    func dynamicHeight(content: String, font: UIFont, width: CGFloat) -> CGFloat {
        if let height = self.noteHeight {
            return height
        } else {
            let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
            let textRect = content.bounding(size: size, font: font)
            let height = ceil(textRect.height)
            self.noteHeight = height
            return height
        }
    }
}

