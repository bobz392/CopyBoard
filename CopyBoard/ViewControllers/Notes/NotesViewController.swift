//
//  ViewController.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/12.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {

    let noteView = NoteView()
    var viewModel: NotesViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.noteView.config(withView: self.view)
        
        
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
        
        
        self.noteView.tableView.delegate = self
        self.noteView.tableView.dataSource = self
        
//        let note1 = Note()
//        note1.content = "abc"
//        
//        let note2 = Note()
//        note2.content = "def"
//        
//        let note3 = Note()
//        note3.content = "ghi"
//        
//        DBManager.shared.realm.beginWrite()
//        DBManager.shared.realm.add([note1, note2, note3])
//        try! DBManager.shared.realm.commitWrite()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension NotesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
//        self.noteView.didScroll(scrollView: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        self.noteView.didEndScroll(scrollView: scrollView)
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NoteTableViewCell.rowHeight
    }
}

