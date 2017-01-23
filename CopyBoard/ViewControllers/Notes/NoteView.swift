//
//  NoteView.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/18.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit
import SnapKit

class NoteView {
    let barView = UIView()
    let titleLabel = UILabel()
    let searchButton = UIButton(type: .custom)
    
    let searchBar = UISearchBar()
    
    var collectionView: UICollectionView!

    let holderView = UIView()
    
    private var barShowing = true
    
    func config(withView view: UIView) {
        AppColors.mainBackground.bgColor(to: view)
        self.holderView.alpha = 0
        self.holderView.isHidden = true
        self.holderView.backgroundColor = UIColor.black
    }
    
    func configBarView(view: UINavigationBar) {
        view.addSubview(self.barView)
        self.barView.backgroundColor = UIColor.clear
        self.barView.clipsToBounds = true
        self.barView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.barView.addSubview(self.titleLabel)
        self.titleLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        self.titleLabel.text = "STICKER"
        self.titleLabel.textAlignment = .center
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()//.offset(10)
            make.left.greaterThanOrEqualToSuperview().offset(60)
            make.right.greaterThanOrEqualToSuperview().offset(-60)
        }
        
        self.barView.addSubview(self.searchButton)
        self.searchButton.setImage(Icons.search.iconImage(), for: .normal)
        self.searchButton.tintColor = AppColors.mainIcon
        self.searchButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
            make.width.equalTo(32)
            make.right.equalToSuperview().offset(-8)
        }
        
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
    }
}

// MARK: - collection view
extension NoteView {
    
    fileprivate func layoutColumnCount() -> Int {
        let dm = DeviceManager.shared
        return dm.isPad() ? (dm.isLandscape() ? 4 : 3) : (dm.isLandscape() ? 3 : 2)
    }
    
    func invalidateLayout() {
        if let layout =
            self.collectionView.collectionViewLayout as? CHTCollectionViewWaterfallLayout {
            layout.columnCount = self.layoutColumnCount()
            self.collectionView.performBatchUpdates({ 
                layout.invalidateLayout()
            }, completion: { (finish) in
//                self.collectionView.contentOffset = CGPoint.zero
            })
        }
    }
    
    func collectionViewItemSpace() -> CGFloat {
        return DeviceManager.shared.isPhone() ? 12.0 : 18.0
    }
    
    func configCollectionView(view: UIView, delegate: NoteCollectionViewLayoutDelegate) {
        let layout = CHTCollectionViewWaterfallLayout()
        let space = self.collectionViewItemSpace()
        
        layout.minimumInteritemSpacing = space
        layout.minimumColumnSpacing = space
        layout.columnCount = self.layoutColumnCount()
        layout.itemRenderDirection = .leftToRight
        let inset = space * 0.5
        layout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset)
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.endSearchAction))
        self.holderView.addGestureRecognizer(tap)
        
        view.addSubview(self.holderView)
        self.holderView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.collectionView)
            make.bottom.equalToSuperview()
        }
        self.collectionView.register(NoteCollectionViewCell.nib,
                                     forCellWithReuseIdentifier: NoteCollectionViewCell.reuseId)
        self.collectionView.bgClear()
    }
    
}

// MARK: - search
extension NoteView {
    
    @objc func endSearchAction() {
        self.searchAnimation(startSearch: false)
    }
    
    func searchAnimation(startSearch: Bool) {
        let weakSelf = self
        let labelCenterY: CGFloat = startSearch ? 44 : 0
        let searchButtonRight: CGFloat = startSearch ? 44 : -8
        self.searchBar.text = nil
        
        if startSearch {
            weakSelf.titleLabel.snp.updateConstraints({ (make) in
                make.centerY.equalToSuperview().offset(labelCenterY)
            })
            
            weakSelf.searchButton.snp.updateConstraints({ (make) in
                make.right.equalToSuperview().offset(searchButtonRight)
            })
            weakSelf.searchBar.setShowsCancelButton(true, animated: false)
            weakSelf.searchBar.becomeFirstResponder()
            weakSelf.holderView.isHidden = false
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                weakSelf.barView.layoutIfNeeded()
                weakSelf.holderView.alpha = 0.3
                weakSelf.titleLabel.alpha = 0
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
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                weakSelf.searchBar.alpha = 0
                weakSelf.holderView.alpha = 0
            }) { (finish) in
                weakSelf.holderView.isHidden = true
                weakSelf.titleLabel.snp.updateConstraints({ (make) in
                    make.centerY.equalToSuperview().offset(labelCenterY)
                })
                
                weakSelf.searchButton.snp.updateConstraints({ (make) in
                    make.right.equalToSuperview().offset(searchButtonRight)
                })
                weakSelf.searchBar.isHidden = true
                weakSelf.searchBar.resignFirstResponder()
                UIView.animate(withDuration: 0.25, animations: {
                    weakSelf.barView.layoutIfNeeded()
                    weakSelf.titleLabel.alpha = 1
                    weakSelf.searchButton.alpha = 1
                })
            }
        }
    }
}
