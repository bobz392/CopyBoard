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
    fileprivate var animator: NoteModalTransitionAnimator? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.noteView.config(withView: self.view)
        if let bar = self.navigationController?.navigationBar {
            self.noteView.configBarView(view: bar)
        }
        self.noteView.configCollectionView(view: self.view, delegate: self)
        
        //        let searchResultDriver =
        //            self.noteView.searchBar.rx.text.orEmpty.asDriver()
        
        self.viewModel = NotesViewModel()
        //            searchDriver: searchResultDriver,
        //            holderViewAlpha: self.noteView.holderView.rx.alpha
        //        )
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
        
        #if debug
            Note.noteTestData()
        #endif
    }
    
    func endSearchAction() {
        self.noteView.searchAnimation(startSearch: false)
        self.viewModel.isInSearch = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(self.noteView.collectionView, delay: 20.0)
            navigationController.expandOnActive = false
            navigationController.scrollingNavbarDelegate = self
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.stopFollowingScrollView()
            navigationController.scrollingNavbarDelegate = nil
        }
    }
    
    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.removeObserver(self)
        DBManager.shared.unbindNotify()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
extension NotesViewController: ScrollingNavigationControllerDelegate {
    
    func deviceOrientationChanged() {
        NoteCollectionViewInputOverlay.closeOpenItem()
        self.noteView.invalidateLayout()
    }
    
    func scrollingUpdateAlphaView() -> UIView? {
        return self.noteView.barView
    }
    
}

// MARK: collection view
extension NotesViewController: UICollectionViewDelegate, UICollectionViewDataSource, NoteCollectionViewLayoutDelegate, CHTCollectionViewDelegateWaterfallLayout {
    
    func presentEditorVC(note: Note) {
        let editorVC = EditorViewController(note: note)
        editorVC.view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        
        let animator = NoteModalTransitionAnimator(modalViewController: editorVC)
        self.animator = animator
        // create animator object with instance of modal view controller
        // we need to keep it in property with strong reference so it will not get release
        animator.dragable = true
        animator.setContentScrollView(editorVC.editorView.editorTextView as UIScrollView)
        animator.direction = .bottom
        
        // set transition delegate of modal view controller to our object
        editorVC.transitioningDelegate = animator
        
        // if you modal cover all behind view controller, use UIModalPresentationFullScreen
        editorVC.modalPresentationStyle = UIModalPresentationStyle.custom;
        self.present(editorVC, animated: true) {
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.viewModel.notesCount()
        self.noteView.emptyNotesView(hidden: count > 0)
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let note = self.viewModel.noteIn(row: indexPath.row)
        self.presentEditorVC(note: note)
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

