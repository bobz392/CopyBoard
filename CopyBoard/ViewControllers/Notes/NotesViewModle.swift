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

class NotesViewModel {
    typealias SearchBlock = (String) -> Void
    let disposeBag = DisposeBag()
    var notes: Results<Note>
    var isInSearch = false
    var isQueryStringEmpty = true
    var searchNotes = [Note]()
    let searchBlock: SearchBlock
    let showFilterSubject = BehaviorSubject<Bool>(value: false)
    
    init(
        searchDriver: Driver<String>,
        searchBlock: @escaping SearchBlock) {
            self.searchBlock = searchBlock
            self.notes = DBManager.shared
                .queryNotes(color: AppSettings.shared.filterColorType)
            
            let time: RxTimeInterval = .milliseconds(500)
            let search = searchDriver
                .throttle(time)
                .skip(1)
                .distinctUntilChanged()
                .flatMapLatest { (query) -> Driver<NotesSearchState> in
                    if query.isEmpty {
                        return Driver.just(NotesSearchState.empty)
                    } else {
                        let notes = DBManager.shared
                            .queryNotes(contain: query, color: AppSettings.shared.filterColorType)
                        let errorReturn = Driver
                            .just(NotesSearchState(notes: [], searchString: query))
                        if notes.isEmpty {
                            return errorReturn
                        } else {
                            let k = Observable.just(NotesSearchState(notes: Array(notes), searchString: query))
                            return k.asDriver(onErrorJustReturn: NotesSearchState(notes: [], searchString: query))
                        }
                    }
                }
            
            search.asObservable()
                .subscribe({ [unowned self] stateEvent in
                    guard self.isInSearch else { return }
                    Logger.log(stateEvent.element ?? "no state")
                    if let s = stateEvent.element {
                        self.searchNotes = s.notes
                        self.isQueryStringEmpty = s.searchString.count <= 0
                        self.searchBlock(s.searchString)
                    }
                })
                .disposed(by: disposeBag)
        }
    
    func refreshNote() {
        notes = DBManager.shared
            .queryNotes(color: AppSettings.shared.filterColorType)
    }
    
    private func useSearchNotes() -> Bool {
        return isInSearch && !isQueryStringEmpty
    }
    
    func notesCount() -> Int {
        return useSearchNotes() ? searchNotes.count : notes.count
    }
    
    func noteIn(row: Int) -> Note {
        return useSearchNotes() ? searchNotes[row] : notes[row]
    }
    
}

struct NotesData {
    var notes: [Note]
    
    init(notes: [Note]) {
        self.notes = notes
    }
}

//
//extension NotesData: AnimatableSectionModelType {
//    typealias Item = Note
//    typealias Identity = String
//    
//    var items: [Note] {
//        get {
//            return self.notes
//        }
//    }
//    
//    var identity: String {
//        get {
//            return "header"
//        }
//    }
//    
//    init(original: NotesData, items: [Item]) {
//        self = original
//        self.notes = items
//    }
//    
//}

struct NotesSearchState {
    let notes: [Note]
    let searchString: String
    
    static let empty = NotesSearchState(notes: [], searchString: "")
}

