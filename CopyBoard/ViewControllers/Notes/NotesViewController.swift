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
    
    override func viewDidLoad() {
        self.isHeroEnabled = false
        
        super.viewDidLoad()
    
        self.noteView.config(withView: self.view)
        self.noteView.configCollectionView(view: self.view, delegate: self)
        
        self.viewModel = NotesViewModel()

        DBManager.shared.bindNotifyToken(result: self.viewModel.notes, dataSource: self)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceOrientationChanged), name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
        
        let weakSelf = self
        self.noteView.searchButton.rx.tap.subscribe { (tap) in
            weakSelf.noteView.searchAnimation(startSearch: true)
            weakSelf.viewModel.isInSearch = true
            }.addDisposableTo(viewModel.disposeBag)
        
        self.noteView.searchBar.rx.cancelButtonClicked.subscribe { (cancel) in
            weakSelf.noteView.searchAnimation(startSearch: false)
            weakSelf.viewModel.isInSearch = false
            }.addDisposableTo(viewModel.disposeBag)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.endSearchAction))
        self.noteView.holderView.addGestureRecognizer(tap)
        
        self.noteView.collectionView.delegate = self
        self.noteView.collectionView.dataSource = self
        
        self.isHeroEnabled = false
        
        #if debug
            Note.noteTestData()
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.selectedCell?.willLeaveEditor()
        self.selectedCell = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.removeObserver(self)
        DBManager.shared.unbindNotify()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func endSearchAction() {
        self.noteView.searchAnimation(startSearch: false)
        self.viewModel.isInSearch = false
    }

}

// MARK: - realm notification datasource
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
    
    func deviceOrientationChanged() {
        NoteCollectionViewInputOverlay.closeOpenItem()
        self.noteView.invalidateLayout()
    }
    
}

// MARK: collection view
extension NotesViewController: UICollectionViewDelegate, UICollectionViewDataSource, NoteCollectionViewLayoutDelegate, CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.viewModel.notesCount()
        self.noteView.emptyNotesView(hidden: count > 0)
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath)
            as? NoteCollectionViewCell else { return }
        
        let note = self.viewModel.noteIn(row: indexPath.row)
        let editorVC = EditorViewController(note: note)
        let weakSelf = self
        let toBlock = { () -> Void in
            let row = indexPath.row
            cell.headerView.heroID = "\(row)header"
            let duration = 0.35
            cell.headerView.heroModifiers = [.duration(duration)]
            
            cell.cardView.heroID = "\(row)card"
            cell.cardView.heroModifiers = [.duration(duration)]
            weakSelf.noteView.collectionView.heroModifiers = [.scale(1.5), .fade, .duration(duration)]
            
            let p = CGPoint(x: weakSelf.noteView.barView.center.x, y: -96)
            weakSelf.noteView.barView.heroModifiers = [.fade, .duration(duration), .position(p)]
            
            cell.faveButton.heroID = "\(row)star"
            editorVC.editorView.faveButton.heroID = "\(row)star"
            cell.faveButton.heroModifiers = [.fade, .duration(duration)]
            
            editorVC.isHeroEnabled = true
            editorVC.editorView.barView.heroID = "\(row)header"
            editorVC.editorView.barView.heroModifiers = [.duration(duration)]
            
            editorVC.view.heroID = "\(row)card"
            editorVC.view.heroModifiers = [.duration(duration)]
            
            editorVC.editorView.barView.backgroundColor = cell.headerView.backgroundColor
            editorVC.view.backgroundColor = cell.cardView.backgroundColor
            
            weakSelf.present(editorVC, animated: true, completion: nil)
        }
        
        cell.willToEditor(block: toBlock)
        self.selectedCell = cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCollectionViewCell.reuseId, for: indexPath) as! NoteCollectionViewCell
        let note = self.viewModel.noteIn(row: indexPath.row)
        cell.configCell(use: note)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, heightForRowAt indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        let note = self.viewModel.noteIn(row: indexPath.row)
        let layout = collectionView.collectionViewLayout as! NoteCollectionViewLayout
        
        let font = appFont(size: 16)
        let height = self.dynamicHeight(content: note.content, font: font, width: layout.itemWidth - 10)
        return height + 35.0
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
        let calString = NSString(string: content)
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let textRect = calString.boundingRect(with: size, options: [NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading], attributes: [NSFontAttributeName: font], context: nil)
        return ceil(textRect.height)
    }
    
}

