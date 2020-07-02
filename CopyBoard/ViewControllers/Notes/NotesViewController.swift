//
//  ViewController.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/12.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit
//import WhatsNewKit
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
        noteView.config(withView: self.view)
        
        weak var weakSelf = self
        noteView.configCollectionView(view: self.view, delegate: self) {
            guard let ws = weakSelf else { return }
            ws.createAction()
        }
        
        //        interstitial = self.createAndLoadInterstitial()
        
        let searchDriver = noteView.searchBar.rx.text.orEmpty.asDriver()
        self.viewModel =
            NotesViewModel(searchDriver: searchDriver,
                           searchBlock:
                { (query) in
                    guard let ws = weakSelf else { return }
                    ws.noteView.searchViewStateChange(query: query.count > 0, notesCount: ws.viewModel.notesCount())
            })
        
        AppSettings.shared.register(any: self,
                                    key: appSettingNotifyKey)
        DBManager.shared
            .bindNotifyToken(result: viewModel.notes,
                             dataSource: self)
        
        noteView.searchButton
            .addTarget(self,
                       action: #selector(searchAction),
                       for: .touchUpInside)
        noteView.settingButton
            .addTarget(self,
                       action: #selector(settingAction),
                       for: .touchUpInside)
        noteView.emptyCreateButton
            .addTarget(self,
                       action: #selector(createAction),
                       for: .touchUpInside)
        noteView.filterButton
            .addTarget(self,
                       action: #selector(filterAction),
                       for: .touchUpInside)
        
        noteView.searchBar
            .rx.cancelButtonClicked
            .subscribe ({ (cancel) in
                guard let ws = weakSelf else { return }
                Logger.log(UIPasteboard.general.string ?? "no")
                ws.endSearchAction()
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
        
        viewModel.showFilterSubject
            .skip(1)
            .subscribe(onNext: { (show) in
                guard let ws = weakSelf else { return }
                let height: CGFloat = show ? kFilterViewHeight : 0
                ws.noteView.filterColorView
                    .snp.updateConstraints { (maker) in
                        maker.height.equalTo(height)
                }
                UIView.animate(withDuration: 0.25) {
                    ws.view.layoutIfNeeded()
                }
            })
            .disposed(by: viewModel.disposeBag)
        
        noteView.filterColorView
            .segment
            .addTarget(self,
                       action: #selector(filterChangeAction(seg:)),
                       for: .valueChanged)
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
        
        if let show =
            try? viewModel.showFilterSubject.value(),
            let _ = AppSettings.shared.filterColorType {
            if !show {
                self.filterAction()
            }
        }
//        showNewFeature()
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
        noteView.searchAnimation(startSearch: true)
        viewModel.isInSearch = true
        NoteCollectionViewInputOverlay.closeOpenItem()
    }
    
    @objc func settingAction() {
        let settingVC = SettingViewController()
        let navigation = UINavigationController(rootViewController: settingVC)
        navigation.transitioningDelegate = self
        navigation.isNavigationBarHidden = true
        transitionType = .ping
        present(navigation, animated: true, completion: nil)
    }
    
    @objc func endSearchAction() {
        noteView.searchAnimation(startSearch: false)
        if !viewModel.isQueryStringEmpty {
            noteView.collectionView.reloadData()
        }
        viewModel.isInSearch = false
        viewModel.isQueryStringEmpty = true
    }
    
    @objc func createAction() {
        let defaultContent = self.noteView.searchBar.text ?? ""
        let dc = defaultContent.count > 0 ? defaultContent : " "
        let color = AppSettings.shared.filterColorType
        let editorVC =
            EditorViewController(defaultContent: dc,
                                 color: color)
        editorVC.transitioningDelegate = self
        transitionType = .present
        present(editorVC, animated: true) {
            self.noteView.stopLoading()
            self.noteView.barView.alpha = 1.0
        }
    }
    
    @objc func filterAction() {
        guard let showFilter =
            try? !viewModel.showFilterSubject.value()
            else { return }
        
        viewModel.showFilterSubject.onNext(showFilter)
        if showFilter {
            noteView.filterButton.tintColor = AppColors.faveButton
        } else {
            noteView.filterButton.tintColor = AppColors.mainIcon
        }
    }
    
    @objc func filterChangeAction(seg: UISegmentedControl) {
        NoteCollectionViewInputOverlay.closeOpenItem()
        if seg.selectedSegmentIndex == 0 {
            AppSettings.shared.filterColorNote = kFilterNoneType
        } else {
            AppSettings.shared.filterColorNote = "\(seg.selectedSegmentIndex - 1)"
        }
    }
    
    override func deviceOrientationChanged() {
        Logger.log("deviceOrientationChanged")
        NoteCollectionViewInputOverlay.closeOpenItem()
        noteView.invalidateLayout()
        
        noteView.filterColorView.snp
            .updateConstraints { (maker) in
                maker.top.equalToSuperview()
                    .offset(DeviceManager.shared.mainHeight)
        }
        
        self.view.layoutIfNeeded()
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
            // 如果是增加和删除都有的话，就直接 reload
            self.noteView.collectionView.reloadData()
        } else {
            noteView.collectionView.performBatchUpdates({ [weak self] in
                guard let ws = self else { return }
                if insertions.count > 0 {
                    ws.noteView.collectionView
                        .insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })
                } else if deletions.count > 0 {
                    ws.noteView.collectionView
                        .deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
                } else if modifications.count > 0 {
                    ws.noteView.collectionView
                        .reloadItems(at: modifications.map { IndexPath(row: $0, section: 0) })
                }
                }, completion: { [weak self] finish in
                    if finish {
                        self?.noteView.collectionView.reloadData()
                    }
            })
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
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        let count = viewModel.notesCount()
        if !viewModel.isInSearch {
            noteView.emptyNotesView(hidden: count > 0)
            if let show =
                try? viewModel.showFilterSubject.value() {
                if count <= 0 && !show {
                    self.filterAction()
                }
            }
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
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
    
    func collectionView(_ collectionView: UICollectionView,
                        didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? NoteCollectionViewCell {
            UIView.animate(withDuration: 0.4, animations: {
                cell.madeShadow(highlight: false)
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? NoteCollectionViewCell {
            UIView.animate(withDuration: 0.25, animations: { 
                cell.madeShadow(highlight: true)
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: NoteCollectionViewCell.reuseId,
                                 for: indexPath) as! NoteCollectionViewCell
        let note = self.viewModel.noteIn(row: indexPath.row)
        let query = self.noteView.searchBar.text
        cell.configCell(use: note, query: query)
        resetTargetAction(cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    func resetTargetAction(cell: NoteCollectionViewCell,
                           indexPath: IndexPath) {
        cell.catelogueButton.tag = indexPath.row;
        cell.deleteButton.tag = indexPath.row;
        cell.catelogueButton
            .removeTarget(self,
                          action: nil, for: .touchUpInside)
        cell.catelogueButton
            .addTarget(self,
                       action: #selector(changeCatelogue(sender:)),
                       for: .touchUpInside)
        
        cell.deleteButton
            .removeTarget(self,
                          action: nil, for: .touchUpInside)
        cell.deleteButton
            .addTarget(self,
                       action: #selector(deleteNoteAction(sender:)),
                       for: .touchUpInside)
    }
    
    @objc func changeCatelogue(sender: UIButton) {
        let note = viewModel.noteIn(row: sender.tag)
        
        let alertController = UIAlertController(title: Localized("changeCatelogue"),
                                                message: "",
                                                preferredStyle: .alert)
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
    
    @objc func deleteNoteAction(sender: UIButton) {
        let indexPath = IndexPath(item: sender.tag, section: 0)
        guard let cell = noteView
            .collectionView.cellForItem(at: indexPath) as? NoteCollectionViewCell else {
            return
        }
        cell.deleteAction(targetCtl: self)
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
            viewModel.notes = DBManager
                .shared
                .queryNotes()
            DBManager.shared
                .bindNotifyToken(result: viewModel.notes,
                                 dataSource: self)
            
        case .hideCreateButton:
            noteView.createButton.isHidden =
                AppSettings.shared.hideCreateButton
        
        case .filterColorNote:
            viewModel.refreshNote()
            noteView.collectionView.reloadData()
             
        default:
            return
        }
    }
    
}

// MARK: - Whats New
extension NotesViewController {
    
    func showNewFeature() {
        
//        let whatsNew = WhatsNew(
//            // The Title
//            title: "Memo",
//            // The features you want to showcase
//            items: [
//                WhatsNew.Item(
//                    title: "Installation",
//                    subtitle: "You can install WhatsNewKit via CocoaPods or Carthage",
//                    image: Icons.filter.iconImage()
//                ),
//                WhatsNew.Item(
//                    title: "Open Source",
//                    subtitle: "Contributions are very welcome 👨‍💻",
//                    image: UIImage(named: "openSource")
//                )
//            ]
//        )
//
//        let whatsNewViewController = WhatsNewViewController(
//            whatsNew: whatsNew
//        )
//
//        present(whatsNewViewController, animated: true)
    }
}
