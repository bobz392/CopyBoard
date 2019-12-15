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
        if let bar = navigationController?.navigationBar {
            self.noteView.configBarView(bar: bar)
        }
        self.noteView.config(withView: self.view)
        
        let weakSelf = self
        noteView
            .configCollectionView(view: self.view, delegate: self) {
                weakSelf.createAction()
        }
        
        //        interstitial = self.createAndLoadInterstitial()
        
        let searchDriver = noteView.searchBar.rx.text.orEmpty.asDriver()
        self.viewModel =
            NotesViewModel(searchDriver: searchDriver,
                           searchBlock:
                { (query) in
                    weakSelf.noteView
                        .searchViewStateChange(query: query.count > 0,
                                               notesCount: weakSelf.viewModel.notesCount())
            })
        
        AppSettings.shared.register(any: self,
                                    key: appSettingNotifyKey)
        DBManager.shared
            .bindNotifyToken(result: viewModel.notes,
                             dataSource: self)
        
        noteView.searchButton
            .addTarget(self,
                       action: #selector(self.searchAction),
                       for: .touchUpInside)
        noteView.settingButton
            .addTarget(self,
                       action: #selector(self.settingAction),
                       for: .touchUpInside)
        noteView.emptyCreateButton
            .addTarget(self,
                       action: #selector(self.createAction),
                       for: .touchUpInside)
        
        noteView.searchBar
            .rx.cancelButtonClicked
            .subscribe ({ (cancel) in
                Logger.log(UIPasteboard.general.string ?? "no")
                weakSelf.endSearchAction()
            })
            .disposed(by: viewModel.disposeBag)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.endSearchAction))
        noteView.searchHolderView.addGestureRecognizer(tap)
        
        if #available(iOS 9.0, *) {
            registerPerview(sourceViewBlock: { [unowned self] () -> UIView in
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
        if #available(iOS 11.0, *) {
            noteView.collectionView.contentInsetAdjustmentBehavior = .never;
            additionalSafeAreaInsets =
                UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        noteView.searchKeyboardHandle()
        noteView.configCreateButton(withView: self.view)
        noteView.createButton
            .addTarget(self,
                       action: #selector(createAction),
                       for: .touchUpInside)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        noteView.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noteView.barView.alpha = 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        selectedCell?.deselectCell()
        selectedCell = nil
        
        MessageViewBuilder
            .showMessageViewIfFirstUse(checkKey: kFirstUseNoteKey)
    }
    
    deinit {
        AppSettings.shared.unregister(key: appSettingNotifyKey)
        DBManager.shared.unbindNotify()
        KeyboardManager.shared.removeHander()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func searchAction()  {
        self.noteView.searchAnimation(startSearch: true)
        self.viewModel.isInSearch = true
        NoteCollectionViewInputOverlay.closeOpenItem()
    }
    
    @objc func settingAction() {
        let settingVC = SettingViewController()
        let navigation = UINavigationController(rootViewController: settingVC)
        navigation.transitioningDelegate = self
        navigation.isNavigationBarHidden = true
        self.transitionType = .ping
        self.present(navigation, animated: true, completion: nil)
    }
    
    @objc func endSearchAction() {
        self.noteView.searchAnimation(startSearch: false)
        if !self.viewModel.isQueryStringEmpty {
            self.noteView.collectionView.reloadData()
        }
        self.viewModel.isInSearch = false
        self.viewModel.isQueryStringEmpty = true
    }
    
    @objc func createAction() {
        let defaultContent = self.noteView.searchBar.text ?? ""
        let editorVC = EditorViewController(defaultContent: defaultContent.count > 0 ? defaultContent : " ")
        editorVC.transitioningDelegate = self
        self.transitionType = .present
        self.present(editorVC, animated: true) {
            self.noteView.collectionView.dg_stopLoading()
            self.noteView.barView.alpha = 1.0
        }
        //        if false == MessageViewBuilder.kFirstNoteKey.valueForKeyInUserDefault() {
        //            MessageViewBuilder.hiddenMessageView()
        //            MessageViewBuilder.kFirstNoteKey.saveToUserDefault(value: true)
        //        }
    }
    
    override func deviceOrientationChanged() {
        Logger.log("deviceOrientationChanged")
        NoteCollectionViewInputOverlay.closeOpenItem()
        self.noteView.invalidateLayout()
        
        self.noteView.collectionView.snp.updateConstraints { (maker) in
            maker.top.equalToSuperview().offset(DeviceManager.shared.mainHeight)
        }
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
            noteView.collectionView.performBatchUpdates({ [weak self] in
                if insertions.count > 0 {
                    self?.noteView.collectionView
                        .insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })
                } else if deletions.count > 0 {
                    self?.noteView.collectionView
                        .deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
                } else if modifications.count > 0 {
                    self?.noteView.collectionView
                        .reloadItems(at: modifications.map { IndexPath(row: $0, section: 0) })
                }
                }, completion: nil)
        }
    }
    
}

// MARK: transition and orientation
extension NotesViewController: UIViewControllerTransitioningDelegate, PingStartViewDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if transitionType == .present {
            let transition = PresentTransition()
            transition.reverse = true
            return transition
        } else if transitionType == .ping {
            let transition = PingTransition()
            transition.reverse = true
            return transition
        } else {
            return nil
        }
    }
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if transitionType == .present {
            let transition = PresentTransition()
            transition.reverse = false
            return transition
        } else if transitionType == .ping {
            let transition = PingTransition()
            transition.reverse = false
            return transition
        } else {
            return nil
        }
    }
    
    func startView() -> UIView {
        return noteView.settingButton
    }
    
}

// MARK: collection view
extension NotesViewController: UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = viewModel.notesCount()
        if !viewModel.isInSearch {
            noteView.emptyNotesView(hidden: count > 0)
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath)
            as? NoteCollectionViewCell else { return }
        
        if cell.canEnter() {
            let note = viewModel.noteIn(row: indexPath.row)
            let editorVC = EditorViewController(note: note)
            editorVC.transitioningDelegate = self
            transitionType = .present
            selectedCell = cell
            present(editorVC, animated: true, completion: nil)
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
        cell.catelogueButton.tag = indexPath.row;
        cell.catelogueButton
            .removeTarget(self,
                          action: #selector(self.changeCatelogue(sender:)),
                          for: .touchUpInside)
        cell.catelogueButton
            .addTarget(self,
                       action: #selector(self.changeCatelogue(sender:)),
                       for: .touchUpInside)
        
        return cell
    }
    
    @objc func changeCatelogue(sender: UIButton) {
        let note = self.viewModel.noteIn(row: sender.tag)
        
        let alertController = UIAlertController(title: Localized("changeCatelogue"), message: "", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = note.category
        })
        let confirmAction = UIAlertAction(title: Localized("save"),
                                          style: .default,
                                          handler:
            {(_ action: UIAlertAction) -> Void in
                if let text = alertController.textFields?[0].text,
                    text.count > 0 {
                    DBManager.shared.updateObject {
                        note.category = text
                    }
                }
        })
        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: Localized("cancel"),
                                         style: .cancel,
                                         handler:
            {(_ action: UIAlertAction) -> Void in
                alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView!,
                        layout collectionViewLayout: UICollectionViewLayout!,
                        sizeForItemAt indexPath: IndexPath!) -> CGSize {
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
        case .stickerLine,
             .gesture,
             .dateLabelUse:
            noteView.collectionView.reloadData()
            
        case .stickerSort,
             .stickerSortNewestLast:
            viewModel.notes = DBManager.shared.queryNotes()
            DBManager.shared
                .bindNotifyToken(result: viewModel.notes,
                                 dataSource: self)
            
        case .hideCreateButton:
            noteView.createButton.isHidden =
                AppSettings.shared.hideCreateButton
            
        default:
            return
        }
    }
    
}


