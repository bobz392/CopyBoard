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
    fileprivate let saveBlock: (String?) -> Void
    
    init(content: String, saveBlock: @escaping (String?) -> Void) {
        self.items = content.segmentation()
        self.saveBlock = saveBlock
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
            self.view.backgroundColor = AppColors.mainBackground
            
            collectionView.bgClear()
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.allowsMultipleSelection = true
            collectionView.register(SegmentationCollectionViewCell.nib,
                                    forCellWithReuseIdentifier: SegmentationCollectionViewCell.reuseId)
            
            self.view.addSubview(collectionView)
            collectionView.snp.makeConstraints({ maker in
                maker.left.equalToSuperview().offset(4)
                maker.top.equalToSuperview().offset(4)
                maker.right.equalToSuperview().offset(-4)
                maker.bottom.equalToSuperview().offset(-4)
            })
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.saveAction))
        } else {
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }

    func saveAction() {
        let content = self.items.reduce("") { (str, item) -> String in
            return str + (item.inUse ? item.content : "")
        }
        
        self.saveBlock(content.count > 0 ? content : nil)
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
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.items[indexPath.row].inUse = false
        let cell = collectionView.cellForItem(at: indexPath) as? SegmentationCollectionViewCell
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SegmentationCollectionViewCell.reuseId, for: indexPath) as! SegmentationCollectionViewCell
        cell?.configCellUseItem(segmenttation: self.items[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.items[indexPath.row].inUse = true
        let cell = collectionView.cellForItem(at: indexPath) as? SegmentationCollectionViewCell
        cell?.configCellUseItem(segmenttation: self.items[indexPath.row])
    }
    
}
