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

class NoteView {
    let barView = BarView(sideMargin: 8)
    let searchBar = UISearchBar()
    let searchButton = UIButton(type: .custom)
    
    var collectionView: UICollectionView!
    var emptyNoteView = UIView()
    var searchResultView = UIView()
    let searchHolderView = UIView()
    
    private var barShowing = true
    
    func config(withView view: UIView) {
        AppColors.mainBackground.bgColor(to: view)
        self.searchHolderView.alpha = 0
        self.searchHolderView.isHidden = true
        self.searchHolderView.backgroundColor = UIColor.black
    }
    
    func configBarView(bar: UINavigationBar) {
        bar.addSubview(self.barView)
        AppColors.mainBackground.bgColor(to: self.barView)
        self.barView.clipsToBounds = true
        self.barView.addConstraint()
        
        self.barView.setTitle(title: "STICKER")
        self.barView.appendButtons(buttons: [self.searchButton], left: false)
        self.searchButton.setImage(Icons.search.iconImage(), for: .normal)
        self.searchButton.tintColor = AppColors.mainIcon
        
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
        let searchButtonRight: CGFloat = hidden ? -8 : 44
        self.searchButton.snp.updateConstraints({ (make) in
            make.right.equalToSuperview().offset(searchButtonRight)
        })
        
        UIView.animate(withDuration: 0.25) { [unowned self] in
            self.barView.layoutIfNeeded()
        }   
    }
    
    func searchViewStateChange(query: Bool, notesCount: Int) {
        UIView.animate(withDuration: 0.1) { [unowned self] in
            if query {
                self.searchHolderView.alpha = 0
                if notesCount > 0 {
                    self.searchResultView.alpha = 0
                } else {
                    self.searchResultView.alpha = 1
                }
            } else {
                self.searchResultView.alpha = 0
                self.searchHolderView.alpha = kHolderViewAlpha
            }
        }
        
        self.collectionView.reloadData()
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
    }
    
    func collectionViewItemSpace() -> CGFloat {
        return DeviceManager.shared.isPhone ? 12.0 : 18.0
    }
    
    func configCollectionView(view: UIView, delegate: NotesViewController) {
        let layout = CHTCollectionViewWaterfallLayout()
        let space = self.collectionViewItemSpace()
        
        layout.minimumInteritemSpacing = space
        layout.minimumColumnSpacing = space
        layout.columnCount = DeviceManager.shared.noteColumnCount
        layout.itemRenderDirection = .shortestFirst
        let inset = space * 0.5
        layout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset)
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.keyboardDismissMode = .onDrag
        self.collectionView.alwaysBounceVertical = true
        view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.configEmptyDataView(view: view)

        view.addSubview(self.searchHolderView)
        self.searchHolderView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.collectionView)
            make.bottom.equalToSuperview()
        }
        
        self.configSearchResultView(view: view)
        
        self.collectionView.register(NoteCollectionViewCell.nib,
                                     forCellWithReuseIdentifier: NoteCollectionViewCell.reuseId)
        self.collectionView.bgClear()
        
        self.collectionView.delegate = delegate
        self.collectionView.dataSource = delegate
    }
    
    
    func configEmptyDataView(view: UIView) {
        view.addSubview(self.emptyNoteView)
        self.emptyNoteView.snp.makeConstraints { (make) in
            make.top.equalTo(self.collectionView)
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
            make.centerY.equalToSuperview().multipliedBy(0.8)
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
    
    func configSearchResultView(view: UIView) {
        view.addSubview(self.searchResultView)
        self.searchResultView.snp.makeConstraints { (make) in
            make.top.equalTo(self.collectionView)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        let label = UILabel()
        label.text = "no result"
        self.searchResultView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        AppColors.mainBackground.bgColor(to: self.searchResultView)
        self.searchResultView.alpha = 0
        self.searchResultView.isHidden = true
    }
}

// MARK: - search
extension NoteView {
    
    func searchAnimation(startSearch: Bool) {
        let weakSelf = self
        let labelCenterY: CGFloat = startSearch ? 11 : 0
        let searchButtonRight: CGFloat = startSearch ? 44 : -8
        self.searchBar.text = nil
        
        if startSearch {
            weakSelf.barView.titleLabel.snp.updateConstraints({ (make) in
                make.centerY.equalToSuperview().offset(labelCenterY)
            })
            
            weakSelf.searchButton.snp.updateConstraints({ (make) in
                make.right.equalToSuperview().offset(searchButtonRight)
            })
            weakSelf.searchBar.setShowsCancelButton(true, animated: false)
            weakSelf.searchBar.becomeFirstResponder()
            weakSelf.searchHolderView.isHidden = false
            weakSelf.searchResultView.isHidden = false
            
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
                weakSelf.searchResultView.alpha = 0
            }) { (finish) in
                weakSelf.searchHolderView.isHidden = true
                weakSelf.searchResultView.isHidden = true
                
                weakSelf.barView.titleLabel.snp.updateConstraints({ (make) in
                    make.centerY.equalToSuperview().offset(labelCenterY)
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
}
