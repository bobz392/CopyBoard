//
//  NotesViewModle.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/14.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class NotesViewModel {
    
//    let searchResultDriver: Driver<String>
//    let dataSource = RxTableViewSectionedAnimatedDataSource<NotesData>()
    
//    let inSearch = Variable<Bool>(false)
    let disposeBag = DisposeBag()
    
    var notes = DBManager.shared.queryNotes()
    var isInSearch = false
    var searchNotes = [Note]()
    
    init(
        searchDriver: Driver<String>,
        holderViewAlpha: UIBindingObserver<UIView, CGFloat>
        ) {
//        self.searchResultDriver = searchDriver
//        let searchDriver = searchResultDriver.throttle(0.3)
//            .distinctUntilChanged()
//            .flatMapLatest { (query) -> Driver<NotesSearchState> in
//                if query.isEmpty {
//                    return Driver.just(NotesSearchState.empty)
//                } else {
//                    let notes = DBManager.shared.queryNotes(contain: query)
//                    let errorReturn = Driver.just(NotesSearchState(notes: [], searchString: query))
//                    if notes.isEmpty {
//                        return errorReturn
//                    } else {
//                        let k = Observable.just(NotesSearchState(notes: Array(notes), searchString: query)).startWith(NotesSearchState.empty)
//                        return k.asDriver(onErrorJustReturn: NotesSearchState(notes: [], searchString: query))
//                    }
//                }
//        }
//        
//        searchDriver.asObservable()
//            .takeUntil(inSearch.asObservable())
//            .map { (state) -> CGFloat in
//                debugPrint("holder view alpha = \(state.searchString.isEmpty ? 0.3 : 0)")
//                return state.searchString.isEmpty ? 0.3 : 0
//            }
//            .bindTo(holderViewAlpha)
//            .addDisposableTo(disposeBag)
        
        
//        dataSource.configureCell = { (datas, tableView, indexPath, note) in
//            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
//            cell.textLabel?.text = note.content
//            return cell
//        }
//        
//        let initDataSource = NotesData( notes: Array(DBManager.shared.queryNotes()) )
        
        
        
    }
    
    func notesCount() -> Int {
        return self.isInSearch ? self.searchNotes.count : self.notes.count
    }
    
    func noteIn(row: Int) -> Note {
        return self.isInSearch ? self.searchNotes[row] : self.notes[row]
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

