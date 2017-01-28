//
//  NotesViewModle.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/14.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa
import RxDataSources

class NotesViewModel {
    typealias SearchBlock = (String) -> Void
    let disposeBag = DisposeBag()
    var notes: Results<Note>
    var isInSearch = false
    var isQueryStringEmpty = true
    var searchNotes = [Note]()
    let searchBlock: SearchBlock
    
    init(
        searchDriver: Driver<String>,
        searchBlock: @escaping SearchBlock) {
        
        self.searchBlock = searchBlock
        self.notes = DBManager.shared.queryNotes()
        
        let search = searchDriver.throttle(0.5)
            .distinctUntilChanged()
            .flatMapLatest { (query) -> Driver<NotesSearchState> in
                if query.isEmpty {
                    return Driver.just(NotesSearchState.empty)
                } else {
                    let notes = DBManager.shared.queryNotes(contain: query)
                    let errorReturn = Driver.just(NotesSearchState(notes: [], searchString: query))
                    if notes.isEmpty {
                        return errorReturn
                    } else {
                        let k = Observable.just(NotesSearchState(notes: Array(notes), searchString: query))
                        return k.asDriver(onErrorJustReturn: NotesSearchState(notes: [], searchString: query))
                    }
                }
        }
        
        let insearchVariable = Variable(self.isInSearch).asObservable()
        
        search.asObservable()
            .takeUntil(insearchVariable)
            .subscribe { [unowned self] (state) in
                print(state.element ?? "no state")
                if let s = state.element {
                    self.searchNotes = s.notes
                    self.isQueryStringEmpty = s.searchString.characters.count <= 0
                    self.searchBlock(s.searchString)
                }
            }.addDisposableTo(disposeBag)
    }
    
    private func useSearchNotes() -> Bool {
        return self.isInSearch && !self.isQueryStringEmpty
    }
    
    func notesCount() -> Int {
        return self.useSearchNotes() ? self.searchNotes.count : self.notes.count
    }
    
    func noteIn(row: Int) -> Note {
        return self.useSearchNotes() ? self.searchNotes[row] : self.notes[row]
    }
    
}

extension Note: IdentifiableType {
    typealias Identity = String
    
    var identity: String {
        get {
            return self.uuid
        }
    }
}


struct NotesData {
    var notes: [Note]
    
    init(notes: [Note]) {
        self.notes = notes
    }
}


extension NotesData: AnimatableSectionModelType {
    typealias Item = Note
    typealias Identity = String
    
    var items: [Note] {
        get {
            return self.notes
        }
    }
    
    var identity: String {
        get {
            return "header"
        }
    }
    
    init(original: NotesData, items: [Item]) {
        self = original
        self.notes = items
    }
    
}

struct NotesSearchState {
    let notes: [Note]
    let searchString: String
    
    static let empty = NotesSearchState(notes: [], searchString: "")
}

