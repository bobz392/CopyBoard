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
    
        let searchResultDriver =
            self.noteView.searchBar.rx.text.orEmpty.asDriver()

        viewModel = NotesViewModel(
            searchDriver: searchResultDriver,
            holderViewAlpha: self.noteView.holderView.rx.alpha
        )
       
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
//        Note.noteTestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.notesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.reuseId) as! NoteTableViewCell
        let note = self.viewModel.noteIn(row: indexPath.row)
        cell.noteLabel.text = note.content
        cell.noteDateLabel.text = try! note.createdAt?.colloquialSinceNow().colloquial
        print(try! note.createdAt?.colloquialSinceNow().colloquial ?? "no date")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NoteTableViewCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = self.viewModel.noteIn(row: indexPath.row)
        let editorVC = EditorViewController(note: note)
        self.navigationController?.pushViewController(editorVC, animated: true)
    }
}

extension NotesViewController: UICollectionViewDelegate, UICollectionViewDataSource, NoteCollectionViewLayoutDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.notesCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCollectionViewCell.reuseId, for: indexPath) as! NoteCollectionViewCell
        let note = self.viewModel.noteIn(row: indexPath.row)
        cell.contentLabel.text = note.content
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, heightForRowAt indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        let note = self.viewModel.noteIn(row: indexPath.row)
        let layout = collectionView.collectionViewLayout as! NoteCollectionViewLayout
    
        let font = UIFont.systemFont(ofSize: 16)
        let height = self.dynamicHeight(content: note.content, font: font, width: layout.itemWidth)
        return height + 35.0
    }
    
    func dynamicHeight(content: String, font: UIFont, width: CGFloat) -> CGFloat {
        let calString = NSString(string: content)
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let textRect = calString.boundingRect(with: size, options: [NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading], attributes: [NSFontAttributeName: font], context: nil)
        debugPrint(textRect)
        return ceil(textRect.height)
    }
}

