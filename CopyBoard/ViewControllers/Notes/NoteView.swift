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
    
    var collectionView: UICollectionView!
    let emptyNoteView = UIView()
    let searchNoResultBgView = UIView()
    let searchNoResultView = UIView()
    let searchHolderView = UIView()
    let noResultsLabel = UILabel()
    let catImageView = UIImageView()
    
    fileprivate var barShowing = true
    fileprivate var target: NotesViewController? = nil
    
    func config(withView view: UIView) {
        AppColors.mainBackground.bgColor(to: view)
        self.searchHolderView.alpha = 0
        self.searchHolderView.isHidden = true
        self.searchHolderView.backgroundColor = UIColor.black
    }
    
    func configBarView(bar: UINavigationBar) {
        let barImage = UIImage()
        bar.shadowImage = barImage
        bar.setBackgroundImage(barImage, for: .default)
        
        self.barHolderView.backgroundColor = AppColors.mainBackgroundAlpha
        bar.addSubview(self.barHolderView)
        self.barHolderView.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalToSuperview().offset(-DeviceManager.shared.statusbarHeight)
            maker.bottom.equalToSuperview()
        }
        
        bar.addSubview(self.barView)
        self.barView.bgClear()
        self.barView.clipsToBounds = true
        self.barView.addConstraint()
        
        self.barView.setTitle(title: Localized("sticker"))
        
        self.barView.appendButtons(buttons: [self.searchButton], left: false)
        self.searchButton.setImage(Icons.search.iconImage(), for: .normal)
        self.searchButton.tintColor = AppColors.mainIcon
        
        self.barView.appendButtons(buttons: [self.settingButton], left: true)
        self.settingButton.setImage(Icons.setting.iconImage(), for: .normal)
        self.settingButton.tintColor = AppColors.mainIcon
        
        self.barView.addSubview(self.searchBar)
        self.searchBar.isHidden = true
        self.searchBar.isTranslucent = true
        self.searchBar.barStyle = .default
        self.searchBar.searchBarStyle = .minimal
        self.searchBar.tintColor = UIColor.black
        self.searchBar.alpha = 0
        self.searchBar.showsCancelButton = true
        self.searchBar.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kNoteCellPadding)
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        bar.layoutIfNeeded()
    }
    
    func emptyNotesView(hidden: Bool) {
        self.emptyNoteView.isHidden = hidden
        let searchButtonRight: CGFloat = hidden ? -self.barView.sideMargin : 44
        self.searchButton.snp.updateConstraints({ (make) in
            make.right.equalToSuperview().offset(searchButtonRight)
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
            self.collectionView.collectionViewLayout as? CHTCollectionViewWaterfallLayout {
            layout.columnCount = DeviceManager.shared.noteColumnCount
            self.collectionView.setCollectionViewLayout(layout, animated: true)
            
        }
        UIApplication.shared.setStatusBarHidden(DeviceManager.shared.isLandscape, with: .fade)
        
        let height: CGFloat = self.searchNoResultView.frame.height * 0.4
        self.catImageView.snp.updateConstraints { maker in
            maker.height.equalTo(height)
            maker.width.equalTo(height * 0.7)
        }
        self.barHolderView.snp.updateConstraints { maker in
            maker.top.equalToSuperview().offset(-DeviceManager.shared.statusbarHeight)
        }
        
        self.barView.superview?.layoutIfNeeded()
    }
    
    fileprivate func addRefreshCreate() {
        let weakSelf = self
        let loadingView = PullDismissView(icon: Icons.create, side: 20) { (progress) in
            weakSelf.barView.alpha = 1 - progress
        }
        loadingView.imageView.tintColor = AppColors.mainIcon
        self.collectionView.dg_addPullToRefreshWithActionHandler({ 
            weakSelf.collectionView.dg_stopLoading()
            
            if let t = weakSelf.target {
                let editorVC = EditorViewController(defaultContent: "")
                editorVC.transitioningDelegate = t
                
                t.transitionType = .present
                t.present(editorVC, animated: true, completion: nil)
            }
            
        }, loadingView: loadingView)
        
        self.collectionView.dg_setPullToRefreshFillColor(UIColor.clear)
        self.collectionView.dg_setPullToRefreshBackgroundColor(UIColor.clear)
    }
    
    func configCollectionView(view: UIView, delegate: NotesViewController, target: NotesViewController) {
        self.target = target
        let layout = CHTCollectionViewWaterfallLayout()
        let space = DeviceManager.shared.collectionViewItemSpace
        
        layout.minimumInteritemSpacing = space
        layout.minimumColumnSpacing = space
        layout.columnCount = DeviceManager.shared.noteColumnCount
        layout.itemRenderDirection = .shortestFirst
        let inset = space * 0.5
        layout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset)
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.keyboardDismissMode = .onDrag
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.bgClear()
        self.collectionView.tag = kNoteCollectionViewTag
        view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        // step 2
        self.configEmptyDataView(view: view)
        
        view.addSubview(self.searchHolderView)
        self.searchHolderView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.collectionView)
            make.bottom.equalToSuperview()
        }
        
        // step 3
        self.configSearchResultView(view: view)
        
        self.collectionView.register(NoteCollectionViewCell.nib,
                                     forCellWithReuseIdentifier: NoteCollectionViewCell.reuseId)
        self.collectionView.bgClear()
        
        self.collectionView.delegate = delegate
        self.collectionView.dataSource = delegate
        
        self.addRefreshCreate()
    }
    
    
    func configEmptyDataView(view: UIView) {
        view.addSubview(self.emptyNoteView)
        self.emptyNoteView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.emptyNoteView.isHidden = true
        self.emptyNoteView.bgClear()
        
        let emptyImageView = UIImageView()
        emptyImageView.image = UIImage(named: "empty")
        emptyImageView.contentMode = .scaleAspectFill
        let width: CGFloat = UIScreen.main.bounds.width * 0.33
        let height = width * 1.2
        self.emptyNoteView.addSubview(emptyImageView)
        emptyImageView.snp.makeConstraints { (make) in
            make.width.equalTo(width)
            make.height.equalTo(height)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        let label = UILabel()
        label.textColor = AppColors.emptyText
        self.emptyNoteView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(emptyImageView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        label.font = appFont(size: emptyNotesFont(), weight: UIFontWeightMedium)
        label.text = Localized("emptyNotes")
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
            maker.center.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview()
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
    
    func searchKeyboardHandle(add: Bool) {
        if add {
            KeyboardManager.shared.setHander { [unowned self] (show, height, duration) in
                let view = self.searchNoResultView
                view.snp.updateConstraints({ maker in
                    maker.bottom.equalToSuperview().offset( show ? -height : 0)
                })
                
                self.barHolderView.backgroundColor = show ? AppColors.mainBackgroundAlphaLight : AppColors.mainBackgroundAlpha
                
                UIView.animate(withDuration: duration, animations: {
                    view.layoutIfNeeded()
                })
            }
        } else {
            KeyboardManager.shared.removeHander()
        }
    }
    
    func searchAnimation(startSearch: Bool) {
        let weakSelf = self
        let labelCenterY: CGFloat = startSearch ? 11 : 0
        let searchButtonRight: CGFloat = startSearch ? 44 : -self.barView.sideMargin
        let settingButtonLeft: CGFloat = startSearch ? -44 : self.barView.sideMargin
        self.searchBar.text = nil
        
        if startSearch {
            let index = IndexPath(item: 0, section: 0)
            weakSelf.collectionView.scrollToItem(at: index, at: .top, animated: true)
            weakSelf.barView.titleLabel.snp.updateConstraints({ (make) in
                make.centerY.equalToSuperview().offset(labelCenterY)
            })
            
            weakSelf.settingButton.snp.updateConstraints({ maker in
                maker.left.equalToSuperview().offset(settingButtonLeft)
            })
            
            weakSelf.searchButton.snp.updateConstraints({ (make) in
                make.right.equalToSuperview().offset(searchButtonRight)
            })
            weakSelf.searchBar.setShowsCancelButton(true, animated: false)
            weakSelf.searchBar.becomeFirstResponder()
            weakSelf.searchHolderView.isHidden = false
            weakSelf.searchNoResultBgView.isHidden = false
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                weakSelf.barView.layoutIfNeeded()
                weakSelf.searchHolderView.alpha = kHolderViewAlpha
                weakSelf.barView.titleLabel.alpha = 0
                weakSelf.searchButton.alpha = 0
            }) { (finish) in
                UIView.animate(withDuration: 0.2, animations: {
                    weakSelf.searchBar.isHidden = false
                    weakSelf.searchBar.alpha = 1
                })
                
                UIView.animate(withDuration: 0.2, animations: {
                    weakSelf.searchBar.isHidden = false
                    weakSelf.searchBar.alpha = 1
                }, completion: nil)
            }
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                weakSelf.searchBar.alpha = 0
                weakSelf.searchHolderView.alpha = 0
                weakSelf.searchNoResultBgView.alpha = 0
            }) { (finish) in
                weakSelf.searchHolderView.isHidden = true
                weakSelf.searchNoResultBgView.isHidden = true
                
                weakSelf.barView.titleLabel.snp.updateConstraints({ (make) in
                    make.centerY.equalToSuperview().offset(labelCenterY)
                })
                
                weakSelf.settingButton.snp.updateConstraints({ maker in
                    maker.left.equalToSuperview().offset(settingButtonLeft)
                })
                
                weakSelf.searchButton.snp.updateConstraints({ (make) in
                    make.right.equalToSuperview().offset(searchButtonRight)
                })
                weakSelf.searchBar.isHidden = true
                weakSelf.searchBar.resignFirstResponder()
                
                UIView.animate(withDuration: 0.25, animations: { 
                    weakSelf.barView.layoutIfNeeded()
                    weakSelf.barView.titleLabel.alpha = 1
                    weakSelf.searchButton.alpha = 1
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
