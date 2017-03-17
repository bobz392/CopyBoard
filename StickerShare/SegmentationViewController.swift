//
//  SegmentationViewController.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/3/17.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit
import SnapKit

class SegmentationViewController: UIViewController {

    fileprivate var items: [SegmenttationItem]
    fileprivate let caculatorLabel = UILabel()
    
    init(content: String) {
        self.items = content.segmentation()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let layout = SECollectionViewFlowLayout(autoSelectRows: true, panToDeselect: true, autoSelectCellsBetweenTouches: false) {
            self.caculatorLabel.font = appFont(size: kSegmentationFontSize)
            self.caculatorLabel.textAlignment = .center
            
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 6
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.backgroundColor = AppColors.mainBackground
            let inset: CGFloat = 4
            collectionView.contentInset = UIEdgeInsetsMake(inset, inset, inset, inset)
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.allowsMultipleSelection = true
            collectionView.register(SegmentationCollectionViewCell.nib,
                                    forCellWithReuseIdentifier: SegmentationCollectionViewCell.reuseId)
            
            self.view.addSubview(collectionView)
            collectionView.snp.makeConstraints({ maker in
                maker.left.equalToSuperview()
                maker.top.equalToSuperview()
                maker.right.equalToSuperview()
                maker.bottom.equalToSuperview()
            })
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.saveAction))
        } else {
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }

    func saveAction() {
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SegmentationViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SegmentationCollectionViewCell.reuseId, for: indexPath) as! SegmentationCollectionViewCell
        cell.configCellUseItem(segmenttation: self.items[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let char = self.items[indexPath.row].content
        self.caculatorLabel.text = char
        self.caculatorLabel.sizeToFit()
        return CGSize(width: self.caculatorLabel.frame.width + 10, height: kSegmentationCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.items[indexPath.row].inUse = !self.items[indexPath.row].inUse
        collectionView.reloadItems(at: [indexPath])
    }
    
}
