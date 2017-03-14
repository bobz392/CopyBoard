//
//  ViewController.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/12.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit
//import GoogleMobileAds

class NotesViewController: BaseViewController {
    
    let noteView = NoteView()
    var viewModel: NotesViewModel!
    fileprivate let appSettingNotifyKey = "NotesViewController"
    
    fileprivate var selectedCell: NoteCollectionViewCell? = nil
    fileprivate var noteHeight: CGFloat? = nil
    var transitionType = TransitionType.present
//    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let bar = self.navigationController?.navigationBar {
            self.noteView.configBarView(bar: bar)
        }
        self.noteView.config(withView: self.view)
        
        let weakSelf = self
        self.noteView.configCollectionView(view: self.view, delegate: self) { 
            weakSelf.createAction()
        }
        
//        interstitial = self.createAndLoadInterstitial()
        
        let searchDriver = self.noteView.searchBar.rx.text.orEmpty.asDriver()
        self.viewModel = NotesViewModel(searchDriver: searchDriver, searchBlock: { (query) in
            weakSelf.noteView.searchViewStateChange(query: query.characters.count > 0,
                                                    notesCount: weakSelf.viewModel.notesCount())
        })
        
        AppSettings.shared.register(any: self, key: self.appSettingNotifyKey)
        DBManager.shared.bindNotifyToken(result: self.viewModel.notes, dataSource: self)
        
        self.noteView.searchButton.addTarget(self, action: #selector(self.searchAction), for: .touchUpInside)
        self.noteView.settingButton.addTarget(self, action: #selector(self.settingAction), for: .touchUpInside)
        self.noteView.emptyCreateButton.addTarget(self, action: #selector(self.createAction), for: .touchUpInside)
        self.noteView.searchBar.rx.cancelButtonClicked.subscribe { (cancel) in
            Logger.log(UIPasteboard.general.string ?? "no")
            weakSelf.endSearchAction()
            }.addDisposableTo(viewModel.disposeBag)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.endSearchAction))
        self.noteView.searchHolderView.addGestureRecognizer(tap)
        
//        #if debug
//            Note.noteTestData()
//        #endif
            
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

//        NotificationCenter.default.addObserver(self, selector: #selector(self.changedAction(ntf:)), name: NSNotification.Name.UIPasteboardChanged, object: nil)
    }
    
//    func changedAction(ntf: NSNotification) {
//        Logger.log(ntf)
//        
//        Logger.log(ntf.object)
//        
//        Logger.log(ntf.userInfo)
//    }
    
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
    
    func searchAction()  {
        self.noteView.searchAnimation(startSearch: true)
        self.viewModel.isInSearch = true
        NoteCollectionViewInputOverlay.closeOpenItem()
    }
    
    func settingAction() {
        let settingVC = SettingViewController()
        let navigation = UINavigationController(rootViewController: settingVC)
        navigation.transitioningDelegate = self
        navigation.isNavigationBarHidden = true
        self.transitionType = .ping
        self.present(navigation, animated: true, completion: nil)
    }
    
    func endSearchAction() {
        self.noteView.searchAnimation(startSearch: false)
        if !self.viewModel.isQueryStringEmpty {
            self.noteView.collectionView.reloadData()
        }
        self.viewModel.isInSearch = false
        self.viewModel.isQueryStringEmpty = true
    }
    
    func createAction() {
        let defaultContent = self.noteView.searchBar.text ?? ""
        let editorVC = EditorViewController(defaultContent: defaultContent.characters.count > 0 ? defaultContent : "")
        editorVC.transitioningDelegate = self
        self.transitionType = .present
        self.present(editorVC, animated: true, completion: nil)
    }
    
}

//extension NotesViewController: GADInterstitialDelegate {
//    
//    fileprivate func createAndLoadInterstitial() -> GADInterstitial {
//        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-6224932916922519/2658320385")
//        interstitial.delegate = self
//        let requset = GADRequest()
//        interstitial.load(requset)
//        return interstitial
//    }
//    
//    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
//        self.interstitial = self.createAndLoadInterstitial()
//    }
//    
//    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
//        Logger.log("interstitialDidFail = \(ad)")
//    }
//    
//    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
//        Logger.log("didFailToReceiveAd = \(ad). WithError = \(error)")
//    }
//    
//}

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
            } else if deletions.count > 0 {
                self.noteView.collectionView
                    .deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
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
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? NoteCollectionViewCell {
            UIView.animate(withDuration: 0.4, animations: {
                cell.madeShadow(highlight: false)
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? NoteCollectionViewCell {
            UIView.animate(withDuration: 0.25, animations: { 
                cell.madeShadow(highlight: true)
            })
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


