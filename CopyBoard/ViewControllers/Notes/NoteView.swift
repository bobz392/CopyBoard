//
//  NoteView.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/18.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit
import SnapKit

fileprivate let kHolderViewAlpha: CGFloat = 0.2

let kNoteCollectionViewTag = 109
let kTokenCollectionViewTag = 209

class NoteView {
    
    let barHolderView = UIView()
    let barView = BarView(sideMargin: 6)
    let searchBar = UISearchBar()
    let searchButton = UIButton(type: .custom)
    let settingButton = UIButton(type: .custom)
    let filterButton = UIButton(type: .custom)
    let createButton = UIButton(type: .custom)
    
    let emptyCreateButton = UIButton(type: .system)
    
    var collectionView: UICollectionView!
    let emptyNoteView = UIView()
    let searchNoResultBgView = UIView()
    let searchNoResultView = UIView()
    let searchHolderView = UIView()
    let noResultsLabel = UILabel()
    let catImageView = UIImageView()
    
    fileprivate var barShowing = true
    fileprivate var createBlock: (() -> Void)? = nil
    
    func config(withView view: UIView) {
        AppColors.mainBackground.bgColor(to: view)
        searchHolderView.alpha = 0
        searchHolderView.isHidden = true
        searchHolderView.backgroundColor = UIColor.black
    }
    
    func configBarView(bar: UINavigationBar) {
        let barImage = UIImage()
        bar.shadowImage = barImage
        bar.setBackgroundImage(barImage, for: .default)
        
        barHolderView.backgroundColor = AppColors.mainBackgroundAlpha
        bar.addSubview(barHolderView)
        barHolderView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalToSuperview()
                .offset(-DeviceManager.shared.statusbarHeight)
            maker.bottom.equalToSuperview()
        }
        
        bar.addSubview(barView)
        barView.bgClear()
        barView.clipsToBounds = true
        barView.addConstraint()
        barView.setTitle(title: Localized("sticker"))
        barView.appendButtons(buttons: [searchButton],
                                   left: false)
        
        searchButton.setImage(Icons.search.iconImage(),
                                   for: .normal)
        searchButton.tintColor = AppColors.mainIcon
        
        barView.appendButtons(buttons: [settingButton, filterButton],
                                   left: true)
        Icons.setting.configMainButton(button: settingButton)
        Icons.filter.configMainButton(button: filterButton)
        
        barView.addSubview(searchBar)
        searchBar.isHidden = true
        searchBar.isTranslucent = true
        searchBar.barStyle = .default
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = UIColor.black
        searchBar.alpha = 0
        searchBar.showsCancelButton = true
        searchBar.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
                .offset(kNoteCellPadding)
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        bar.layoutIfNeeded()
    }
    
    func configCreateButton(withView view: UIView) {
        if let icon = Icons.createManual.iconImage() {
            createButton.setImage(icon, for: .normal)
        }
        createButton.backgroundColor = UIColor.white
        createButton.tintColor = AppColors.mainIcon
        createButton.layer.cornerRadius = 22
        createButton.layer.shadowOpacity = 0.2
        createButton.layer.shadowRadius = 2
        createButton.layer.shadowColor = UIColor.black.cgColor
        createButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.addSubview(createButton)
        createButton.snp.makeConstraints { (maker) in
            maker.height.equalTo(44)
            maker.width.equalTo(80)
            maker.centerX.equalToSuperview()
            if #available(iOS 11.0, *) {
                maker.bottom.equalToSuperview()
                    .offset(-20 - view.safeAreaInsets.bottom)
            } else {
                maker.bottom.equalToSuperview()
                    .offset(-20)
            }
        }
    }
    
    func emptyNotesView(hidden: Bool) {
        self.emptyNoteView.isHidden = hidden
        let searchButtonRight: CGFloat = hidden ? -barView.sideMargin : 44
        searchButton.snp.updateConstraints({ (make) in
            make.right.equalToSuperview()
                .offset(searchButtonRight)
        })
        
        UIView.animate(withDuration: 0.25) { [unowned self] in
            self.barView.layoutIfNeeded()
        }
    }
    
}

// MARK: - collection view
extension NoteView {
    
    func invalidateLayout() {
        if let layout =
            collectionView.collectionViewLayout as? CHTCollectionViewWaterfallLayout {
            layout.columnCount = DeviceManager.shared.noteColumnCount
            collectionView.setCollectionViewLayout(layout, animated: true)
            
        }
       
        UIApplication.shared
            .setStatusBarHidden(DeviceManager.shared.isLandscape,
                                with: .fade)
        
        let height: CGFloat = self.searchNoResultView.frame.height * 0.4
        self.catImageView.snp.updateConstraints { maker in
            maker.height.equalTo(height)
            maker.width.equalTo(height * 0.7)
        }
        self.barHolderView.snp.updateConstraints { maker in
            maker.top.equalToSuperview()
                .offset(-DeviceManager.shared.statusbarHeight)
        }
        
        self.barView.superview?.layoutIfNeeded()
    }
    
    fileprivate func addRefreshCreate() {
        let weakSelf = self
        let loadingView =
            PullDismissView(icon: Icons.create,
                            side: 20)
            { (progress) in
                weakSelf.barView.alpha = 1 - progress
        }
        loadingView.imageView.tintColor = AppColors.mainIcon
        collectionView.dg_addPullToRefreshWithActionHandler({
            weakSelf.createBlock?()
        }, loadingView: loadingView)
        
        collectionView.dg_setPullToRefreshFillColor(UIColor.clear)
        collectionView.dg_setPullToRefreshBackgroundColor(UIColor.clear)
    }
    
    func configCollectionView(view: UIView,
                              delegate: NotesViewController,
                              createBlock: @escaping () -> Void) {
        self.createBlock = createBlock
        let layout = CHTCollectionViewWaterfallLayout()
        let space = DeviceManager.shared.collectionViewItemSpace
        
        layout.minimumInteritemSpacing = space
        layout.minimumColumnSpacing = space
        layout.columnCount = DeviceManager.shared.noteColumnCount
        layout.itemRenderDirection = .shortestFirst
        let inset = space * 0.5
        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.keyboardDismissMode = .onDrag
        collectionView.alwaysBounceVertical = true
        collectionView.bgClear()
        collectionView.tag = kNoteCollectionViewTag
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
                .offset(DeviceManager.shared.mainHeight)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        // step 2
        configEmptyDataView(view: view)
        
        view.addSubview(searchHolderView)
        searchHolderView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.collectionView)
            make.bottom.equalToSuperview()
        }
        
        // step 3
        configSearchResultView(view: view)
        
        collectionView.register(NoteCollectionViewCell.nib,
                                forCellWithReuseIdentifier: NoteCollectionViewCell.reuseId)
        
        collectionView.delegate = delegate
        collectionView.dataSource = delegate
        
        addRefreshCreate()
    }
    
    func configEmptyDataView(view: UIView) {
        view.addSubview(emptyNoteView)
        emptyNoteView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        emptyNoteView.isHidden = true
        emptyNoteView.bgClear()
        
        let emptyImageView = UIImageView()
        emptyImageView.image = UIImage(named: "empty")
        emptyImageView.contentMode = .scaleAspectFill
        let width: CGFloat = (min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)) * 0.33
        let height = width * 1.2
        emptyNoteView.addSubview(emptyImageView)
        emptyImageView.snp.makeConstraints { (make) in
            make.width.equalTo(width)
            make.height.equalTo(height)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        emptyCreateButton.setTitle(Localized("create"), for: .normal)
        emptyCreateButton.setTitleColor(AppColors.faveButton, for: .normal)
        emptyNoteView.addSubview(emptyCreateButton)
        emptyCreateButton.snp.makeConstraints { (make) in
            make.top.equalTo(emptyImageView.snp.bottom)
                .offset(15)
            make.centerX.equalToSuperview()
        }
        emptyCreateButton.titleLabel?.font =
            appFont(size: emptyNotesFont(), weight: .medium)
    }
    
    fileprivate func emptyNotesFont() -> CGFloat {
        let dm = DeviceManager.shared
        
        if dm.isPhone {
            switch dm.phoneScreenType() {
            case .phone5:
                return 18
            case .phone6:
                return 20
            case .phone6p:
                return 24
            }
        } else {
            return 0
        }
    }
    
}

// MARK: - search
extension NoteView {
    
    func configSearchResultView(view: UIView) {
        view.addSubview(self.searchNoResultBgView)
        self.searchNoResultBgView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        if let image = UIImage(named: "empty_bg.pdf") {
            self.searchNoResultBgView.layer.contents = image.cgImage
        }
        
        self.searchNoResultBgView.addSubview(self.searchNoResultView)
        self.searchNoResultView.bgClear()
        self.searchNoResultView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
        
        let catImageView = UIImageView()
        self.searchNoResultView.addSubview(catImageView)
        catImageView.image = UIImage(named: "empty_cat")
        self.searchNoResultView.addSubview(catImageView)
        
        let height: CGFloat = view.frame.height * 0.4
        catImageView.snp.makeConstraints { maker in
            maker.height.equalTo(height)
            maker.width.equalTo(height * 0.75)
            maker.right.equalToSuperview().offset(-15)
            maker.bottom.equalToSuperview().offset(-15)
        }
        
        self.noResultsLabel.text = Localized("noResuts")
        self.noResultsLabel.font = appFont(size: 17)
        self.noResultsLabel.textColor = UIColor.white
        self.noResultsLabel.alpha = 0
        self.searchNoResultView.addSubview(self.noResultsLabel)
        self.noResultsLabel.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(30)
            maker.bottom.equalToSuperview().offset(30)
            maker.right.greaterThanOrEqualTo(catImageView.snp.left)
        }
        
        self.searchNoResultBgView.alpha = 0
        self.searchNoResultBgView.isHidden = true
    }
    
    func searchKeyboardHandle() {
        KeyboardManager.shared
            .setHander { [unowned self] (show, height, duration) in
                let view = self.searchNoResultView
                view.snp.updateConstraints({ maker in
                    maker.bottom.equalToSuperview().offset( show ? -height : 0)
                })
                
                self.barHolderView.backgroundColor = show ? AppColors.mainBackgroundAlphaLight : AppColors.mainBackgroundAlpha
                
                UIView.animate(withDuration: duration, animations: {
                    view.layoutIfNeeded()
                })
        }
    }
    
    func searchAnimation(startSearch: Bool) {
        weak var weakSelf = self
        searchBar.text = nil
        
        if startSearch {
            let index = IndexPath(item: 0, section: 0)
            collectionView.scrollToItem(at: index,
                                        at: .top,
                                        animated: true)
            searchBar.setShowsCancelButton(true,
                                           animated: false)
            
            searchHolderView.isHidden = false
            searchNoResultBgView.isHidden = false
            barView.buttonsSearchLayoutChange(startSearch: startSearch)
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                guard let ws = weakSelf else { return }
                ws.barView.layoutIfNeeded()
                ws.searchHolderView.alpha = kHolderViewAlpha
                ws.barView.titleLabel.alpha = 0
                ws.searchButton.alpha = 0
            }) { (finish) in
                guard let ws = weakSelf else { return }
                ws.searchBar.becomeFirstResponder()
                UIView.animate(withDuration: 0.2, animations: {
                    ws.searchBar.isHidden = false
                    ws.searchBar.alpha = 1
                })
            }
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                guard let ws = weakSelf else { return }
                ws.searchBar.alpha = 0
                ws.searchHolderView.alpha = 0
                ws.searchNoResultBgView.alpha = 0
            }) { (finish) in
                guard let ws = weakSelf else { return }
                ws.searchHolderView.isHidden = true
                ws.searchNoResultBgView.isHidden = true
                
                ws.barView.buttonsSearchLayoutChange(startSearch: false)
                ws.searchBar.isHidden = true
                ws.searchBar.resignFirstResponder()
                
                UIView.animate(withDuration: 0.25, animations: { 
                    ws.barView.layoutIfNeeded()
                    ws.barView.titleLabel.alpha = 1
                    ws.searchButton.alpha = 1
                })
            }
        }
    }
    
    func searchViewStateChange(query: Bool, notesCount: Int) {
        if query {
            self.searchHolderView.alpha = 0
            if notesCount > 0 {
                self.searchNoResultBgView.alpha = 0
                self.noResultsLabel(show: false)
            } else {
                self.searchNoResultBgView.alpha = 1
                self.noResultsLabel(show: true)
            }
            
        } else {
            self.searchNoResultBgView.alpha = 0
            self.searchHolderView.alpha = kHolderViewAlpha
            self.noResultsLabel(show: false)
        }
        
        self.collectionView.reloadData()
    }
    
    fileprivate func noResultsLabel(show: Bool) {
        self.noResultsLabel.snp.updateConstraints ({ maker in
            maker.bottom.equalToSuperview().offset(show ? -10 : 30)
        })
        
        UIView.animate(withDuration: show ? 0.6 : 0.1, animations: { [unowned self] in
            self.noResultsLabel.alpha = show ? 1 : 0
            self.searchNoResultView.layoutIfNeeded()
        })
    }
    
}
