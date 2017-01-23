//
//  ViewController.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/12.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class NotesViewController: BaseViewController {

    let noteView = NoteView()
    var viewModel: NotesViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.noteView.config(withView: self.view)
        if let bar = self.navigationController?.navigationBar {
            self.noteView.configBarView(view: bar)
        }
        self.noteView.configCollectionView(view: self.view, delegate: self)
    
//        let searchResultDriver =
//            self.noteView.searchBar.rx.text.orEmpty.asDriver()

        self.viewModel = NotesViewModel()
//            searchDriver: searchResultDriver,
//            holderViewAlpha: self.noteView.holderView.rx.alpha
//        )
        self.viewModel.bindNotifyToken(dataSource: self)
       
        let weakSelf = self
        self.noteView.searchButton.rx.tap.subscribe { (tap) in
            weakSelf.noteView.searchAnimation(startSearch: true)
        }.addDisposableTo(viewModel.disposeBag)
        
        self.noteView.searchBar.rx.cancelButtonClicked.subscribe { (cancel) in
            weakSelf.noteView.searchAnimation(startSearch: false)
        }.addDisposableTo(viewModel.disposeBag)
        
        
        self.noteView.collectionView.delegate = self
        self.noteView.collectionView.dataSource = self
        self.shyNavBarManager.scrollView = self.noteView.collectionView
        
        #if debug
            Note.noteTestData()
        #endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension NotesViewController: RealmNotificationDataSource {
    func dataInit() {
        self.noteView.collectionView.reloadData()
    }
    
    func update(deletions: [Int], insertions: [Int], modifications: [Int]) {
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

// MARK: transition
extension NotesViewController {
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        NoteCollectionViewInputOverlay.closeOpenItem()
        self.noteView.invalidateLayout()
    }
    
}

// MARK: collection view
extension NotesViewController: UICollectionViewDelegate, UICollectionViewDataSource, NoteCollectionViewLayoutDelegate, CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.notesCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCollectionViewCell.reuseId, for: indexPath) as! NoteCollectionViewCell
        let note = self.viewModel.noteIn(row: indexPath.row)
        cell.configCell(use: note)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, heightForRowAt indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        let note = self.viewModel.noteIn(row: indexPath.row)
        let layout = collectionView.collectionViewLayout as! NoteCollectionViewLayout
    
        let font = UIFont.systemFont(ofSize: 16)
        let height = self.dynamicHeight(content: note.content, font: font, width: layout.itemWidth - 10)
        return height + 35.0
    }
    
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAt indexPath: IndexPath!) -> CGSize {
        let note = self.viewModel.noteIn(row: indexPath.row)
        let layout = collectionView.collectionViewLayout as! CHTCollectionViewWaterfallLayout
        
        
        let font = UIFont.systemFont(ofSize: 16)
        let space = CGFloat(layout.columnCount + 1) * self.noteView.collectionViewItemSpace()
        let width = (self.view.frame.width - space) / CGFloat(layout.columnCount)
        let height = self.dynamicHeight(content: note.content, font: font, width: width - 10)
        return CGSize(width: width, height: height + 35)
    }
    
    func dynamicHeight(content: String, font: UIFont, width: CGFloat) -> CGFloat {
        let calString = NSString(string: content)
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let textRect = calString.boundingRect(with: size, options: [NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading], attributes: [NSFontAttributeName: font], context: nil)
        return ceil(textRect.height)
    }
    
}

