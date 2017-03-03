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
    fileprivate let appSettingNotifyKey = "NotesViewController"
    
    fileprivate var selectedCell: NoteCollectionViewCell? = nil
    fileprivate var noteHeight: CGFloat? = nil
    var transitionType = TransitionType.present
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let bar = self.navigationController?.navigationBar {
            self.noteView.configBarView(bar: bar)
        }
        self.noteView.config(withView: self.view)
        self.noteView.configCollectionView(view: self.view, delegate: self, target: self)
        
        let weakSelf = self
        
        let searchDriver = self.noteView.searchBar.rx.text.orEmpty.asDriver()
        self.viewModel = NotesViewModel(searchDriver: searchDriver, searchBlock: { (query) in
            weakSelf.noteView.searchViewStateChange(query: query.characters.count > 0,
                                                    notesCount: weakSelf.viewModel.notesCount())
        })
        
        AppSettings.shared.register(any: self, key: self.appSettingNotifyKey)
        DBManager.shared.bindNotifyToken(result: self.viewModel.notes, dataSource: self)
        
        self.noteView.searchButton.rx.tap.subscribe { (tap) in
            weakSelf.noteView.searchAnimation(startSearch: true)
            weakSelf.viewModel.isInSearch = true
            NoteCollectionViewInputOverlay.closeOpenItem()
            }.addDisposableTo(viewModel.disposeBag)
        
        self.noteView.searchBar.rx.cancelButtonClicked.subscribe { (cancel) in
            weakSelf.endSearchAction()
            }.addDisposableTo(viewModel.disposeBag)
        
        self.noteView.settingButton.rx.tap.subscribe { (tap) in
            let settingVC = SettingViewController()
            let navigation = UINavigationController(rootViewController: settingVC)
            navigation.transitioningDelegate = weakSelf
            navigation.isNavigationBarHidden = true
            weakSelf.transitionType = .ping
            weakSelf.present(navigation, animated: true, completion: nil)
            }.addDisposableTo(viewModel.disposeBag)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.endSearchAction))
        self.noteView.searchHolderView.addGestureRecognizer(tap)
        
        #if debug
            Note.noteTestData()
        #endif
        
        if #available(iOS 9.0, *) {
            self.registerPerview(sourceViewBlock: { [unowned self] () -> UIView in
                return self.noteView.collectionView
                }, previewViewControllerBlock: { [unowned self] (previewingContext: UIViewControllerPreviewing, location: CGPoint) -> UIViewController? in
                    guard let index = self.noteView.collectionView.indexPathForItem(at: location),
                        let cell = self.noteView.collectionView.cellForItem(at: index) else { return nil }
                    let note = self.viewModel.notes[index.row]
                    let editorVC = EditorViewController(note: note)
                    previewingContext.sourceRect = cell.frame
                    editorVC.transitioningDelegate = self
                    self.selectedCell = cell as? NoteCollectionViewCell
                    self.transitionType = .present
                    return editorVC
            })
        }

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.noteView.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.noteView.searchKeyboardHandle(add: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.selectedCell?.deselectCell()
        self.selectedCell = nil
        self.noteView.searchKeyboardHandle(add: true)
    }
    
    deinit {
        AppSettings.shared.unregister(key: self.appSettingNotifyKey)
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
        NoteCollectionViewInputOverlay.closeOpenItem()
        if insertions.count > 0, deletions.count > 0 {
            self.noteView.collectionView.reloadData()
        } else {
            if insertions.count > 0 {
                self.noteView.collectionView
                    .insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })
                //            if self.viewModel.notes.count == 1, !self.viewModel.isInSearch {
                //                self.scrollingNav.followScrollView(self.noteView.collectionView)
                //            }
            } else if deletions.count > 0 {
                self.noteView.collectionView
                    .deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
                //            if self.viewModel.notes.count == 0, !self.viewModel.isInSearch {
                //                self.scrollingNav.stopFollowingScrollView()
                //            }
            } else if modifications.count > 0 {
                self.noteView.collectionView
                    .reloadItems(at: modifications.map { IndexPath(row: $0, section: 0) })
            }
        }
    }
    
}

// MARK: transition and orientation
extension NotesViewController: UIViewControllerTransitioningDelegate, PingStartViewDelegate {
    
    override func deviceOrientationChanged() {
        Logger.log("deviceOrientationChanged")
        NoteCollectionViewInputOverlay.closeOpenItem()
        self.noteView.invalidateLayout()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if self.transitionType == .present {
            let transition = PresentTransition()
            transition.reverse = true
            return transition
        } else if self.transitionType == .ping {
            let transition = PingTransition()
            transition.reverse = true
            return transition
        } else {
            return nil
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if self.transitionType == .present {
            let transition = PresentTransition()
            transition.reverse = false
            return transition
        } else if self.transitionType == .ping {
            let transition = PingTransition()
            transition.reverse = false
            return transition
        } else {
            return nil
        }
    }
    
    func startView() -> UIView {
        return self.noteView.settingButton
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
        
        if cell.canEnter() {
            let note = self.viewModel.noteIn(row: indexPath.row)
            let editorVC = EditorViewController(note: note)
            editorVC.transitioningDelegate = self
            self.transitionType = .present
            self.selectedCell = cell
            self.present(editorVC, animated: true, completion: nil)
        }
    }
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCollectionViewCell.reuseId, for: indexPath) as! NoteCollectionViewCell
        let note = self.viewModel.noteIn(row: indexPath.row)
        let query = self.noteView.searchBar.text
        cell.configCell(use: note, query: query)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAt indexPath: IndexPath!) -> CGSize {
        let layout = collectionView.collectionViewLayout as! CHTCollectionViewWaterfallLayout
        
        let space = CGFloat(layout.columnCount + 1) * DeviceManager.shared.collectionViewItemSpace
        let width = (self.view.frame.width - space) / CGFloat(layout.columnCount)
        let height = ceil(appFont(size: 16).lineHeight * CGFloat(AppSettings.shared.stickerLines + 4)) + 35
        return CGSize(width: width, height: height)
    }
    
}

extension NotesViewController: AppSettingsNotify {
    
    func settingDidChange(settingKey: UserDefaultsKey) {
        switch settingKey {
        case .stickerLine, .gesture, .dateLabelUse:
            self.noteView.collectionView.reloadData()
            
        case .stickerSort, .stickerSortNewestLast:
            self.viewModel.notes = DBManager.shared.queryNotes()
            DBManager.shared.bindNotifyToken(result: self.viewModel.notes, dataSource: self)
            
        default:
            return
        }
    }
    
}


