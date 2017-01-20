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
    
    let tableView = UITableView()

    let holderView = UIView()
    
    private var barShowing = true
    
    func config(withView view: UIView) {
        AppColors.mainBackground.bgColor(to: view)
        
        let bgImageView = UIImageView()
        view.addSubview(bgImageView)
        bgImageView.image = UIImage(named: "bg3.jpg")
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.configBarView(view: view)
        self.configTableView(view: view)
        
        view.addSubview(self.holderView)
        self.holderView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.tableView)
            make.bottom.equalToSuperview()
        }
        self.holderView.alpha = 0
        self.holderView.isHidden = true
        self.holderView.backgroundColor = UIColor.black
    }
    
    private func configTableView(view: UIView) {
        view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.barView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        self.tableView.register(NoteTableViewCell.nib,
                                forCellReuseIdentifier: NoteTableViewCell.reuseId)
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
//        self.tableView.clipsToBounds = false
        self.tableView.bgClear()
    }
    
    private func configBarView(view: UIView) {
        view.addSubview(self.barView)
        self.barView.bgClear()
        self.barView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(64)
        }
        
        self.barView.addSubview(self.titleLabel)
        self.titleLabel.font = UIFont.systemFont(ofSize: 17)
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(10)
            make.left.greaterThanOrEqualToSuperview().offset(60)
            make.right.greaterThanOrEqualToSuperview().offset(-60)
        }
        
        self.barView.addSubview(self.searchButton)
        self.searchButton.setImage(Icons.search.iconImage(), for: .normal)
        self.searchButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(10)
            make.height.equalTo(32)
            make.width.equalTo(32)
            make.right.equalToSuperview().offset(-8)
        }
        
        self.barView.addSubview(self.searchBar)
        self.searchBar.isHidden = true
        self.searchBar.isTranslucent = true
        self.searchBar.barStyle = .default
        self.searchBar.searchBarStyle = .minimal
        self.searchBar.tintColor = AppColors.mainBackground
        self.searchBar.alpha = 0
        self.searchBar.showsCancelButton = true
        self.searchBar.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

extension NoteView {
    func searchAnimation(startSearch: Bool) {
        let weakSelf = self
        let labelCenterY: CGFloat = startSearch ? 44 : 0
        let searchButtonRight: CGFloat = startSearch ? 44 : -8
        
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
                UIView.animate(withDuration: 0.2, animations: {
                    weakSelf.barView.layoutIfNeeded()
                })
            }
        }
    }
}
