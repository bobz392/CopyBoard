//
//  NoteCollectionViewCell.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/21.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

fileprivate let kCurlDeleteDuration: TimeInterval = 0.4
fileprivate let kCurlOpenDuration: TimeInterval = 0.3
fileprivate let kCurlCloseDuration: TimeInterval = 0.2
let kNoteViewAlphaAnimation: TimeInterval = 0.1
let noteViewShowAlphaAnimation: TimeInterval = 0.5
let kHeroAnimationDuration: TimeInterval = 0.4

class NoteCollectionViewCell: UICollectionViewCell {
    
    static let nib = UINib(nibName: "NoteCollectionViewCell", bundle: nil)
    static let reuseId = "noteCollectionViewCell"
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var faveButton: FaveButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var noteDateLabel: UILabel!
    
    fileprivate var curlView: XBCurlView? = nil
    fileprivate var isCurl = false
    
    var note: Note? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.deleteButton.setImage(Icons.delete.iconImage(), for: .normal)
        self.deleteButton.tintColor = UIColor.white
        self.deleteButton.addTarget(self, action: #selector(self.deleteAction), for: .touchUpInside)
        self.faveButton.addTarget(self, action: #selector(self.favourate), for: .touchUpInside)
        self.noteLabel.textColor = AppColors.noteText
        self.noteDateLabel.textColor = AppColors.noteDate
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.gestureOpenAction))
        swipe.direction = .left
        self.cardView.addGestureRecognizer(swipe)
    }
    
    func configCell(use note: Note, query: String? = nil) {
        guard let pairColor = AppPairColors(rawValue: note.color)?.pairColor() else {
            fatalError("have no this type color")
        }
        pairColor.dark.bgColor(to: self.headerView)
        pairColor.light.bgColor(to: self.cardView)
        
        self.faveButton.isSelected = note.favourite
        self.noteDateLabel.text = try! note.createdAt?.colloquialSinceNow().colloquial
        self.noteLabel.attributedText = note.content.searchHintString(query: query)
        self.note = note
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.madeShadow()
    }
    
    fileprivate func madeShadow() {
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 3
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    // MARK: - action
    func gestureOpenAction() {
        self.connectCollectionViewWithOverlay()
        guard let cv = NoteCollectionViewInputOverlay.cacheCollectionView,
            let index = cv.indexPath(for: self) else { return }
        self.curl(index: index)
    }
    
    func deleteAction() {
        guard let cv = self.curlView else { return }
        
        let weakSelf =  self
        NoteCollectionViewInputOverlay.openedItemIndex = nil
        cv.uncurlAnimated(withDuration: kCurlDeleteDuration) {
            UIView.animate(withDuration: kCurlDeleteDuration, animations: {
                cv.alpha = 0
            }) { (finish) in
                weakSelf.deleteRealmNote()
            }
            weakSelf.curlView = nil
        }
    }
    
    fileprivate func deleteRealmNote() {
        guard  let n = self.note else {
            Logger.log("have no note to delete, maybe check it")
            return
        }
        
        DBManager.shared.deleteNote(note: n)
    }
    
    func favourate() {
        guard  let n = self.note else {
            Logger.log("have no note to delete")
            return
        }
        
        DBManager.shared.updateObject(false) {
            n.favourite = !n.favourite
        }
    }

    
    func willToEditor(block: @escaping () -> Void, row: Int) {
        if self.isCurl {
            return
        }
        
        self.headerView.heroID = "\(row)header"
        self.headerView.heroModifiers = [.duration(kHeroAnimationDuration)]
        
        self.cardView.heroID = "\(row)card"
        self.cardView.heroModifiers = [.duration(kHeroAnimationDuration)]
        
        self.faveButton.heroID = "\(row)star"
        self.faveButton.heroModifiers = [.fade, .duration(kHeroAnimationDuration)]
        
        UIView.animate(withDuration: kNoteViewAlphaAnimation, delay: 0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            self.noteLabel.alpha = 0
            self.layer.shadowOpacity = 0
        }) { (finish) in
            block()
        }
        self.backView.alpha = 0
    }
    
    func willLeaveEditor() {
        self.backView.alpha = 1
        self.headerView.heroID = nil
        self.headerView.heroModifiers = nil
        
        self.cardView.heroID = nil
        self.cardView.heroModifiers = nil
        
        self.faveButton.heroID = nil 
        self.faveButton.heroModifiers = nil
        
        UIView.animate(withDuration: noteViewShowAlphaAnimation, delay: 0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            self.noteLabel.alpha = 1
            self.layer.shadowOpacity = 0.2
        }) { (finish) in }
    }
    
}

// MARK: - curl view
extension NoteCollectionViewCell {
    
    final func curl(index: IndexPath) {
        if self.isCurl {
            self.closeCurl()
        } else {
            guard NoteCollectionViewInputOverlay.openedItemIndex == nil else { return }
            
            let cardBounds = self.cardView.bounds
            self.curlView = XBCurlView(frame: cardBounds)
            self.curlView?.isOpaque = false
            self.curlView?.pageOpaque = true
            
            let rato: CGFloat = DeviceManager.shared.isPhone() ? 0.5 : 0.8
            let p = CGPoint(x: cardBounds.width * rato, y: cardBounds.height * rato)
            let angle = CGFloat(M_PI_2)
            self.curlView?.curl(self.cardView,
                                cylinderPosition: p,
                                cylinderAngle: angle,
                                cylinderRadius: 30,
                                animatedWithDuration: kCurlOpenDuration
            )
            NoteCollectionViewInputOverlay.openedItemIndex = index
            self.isCurl = true
        }
    }
    
    func connectCollectionViewWithOverlay() {
        if !NoteCollectionViewInputOverlay.connected {
            var view = self.superview
            while(view != nil) {
                if let cv = view as? UICollectionView {
                    let overlay = NoteCollectionViewInputOverlay()
                    NoteCollectionViewInputOverlay.cacheCollectionView = cv
                    cv.addSubview(overlay)
                    NoteCollectionViewInputOverlay.connected = true
                    return
                }
                view = view?.superview
            }
        }
    }
    
    fileprivate func closeCurl(duration: Double = kCurlCloseDuration) {
        self.curlView?.uncurlAnimated(withDuration: duration, completion: { [unowned self] in
            self.curlView = nil
            self.isCurl = false
            NoteCollectionViewInputOverlay.openedItemIndex = nil
        })
    }
 
}

final class NoteCollectionViewInputOverlay: UIView {
    static var openedItemIndex: IndexPath? = nil
    static var connected: Bool = false
    static var cacheCollectionView: UICollectionView? = nil
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let index = NoteCollectionViewInputOverlay.openedItemIndex,
            let cv = self.superview as? UICollectionView,
            let cell = cv.cellForItem(at: index) as? NoteCollectionViewCell else { return nil}
        
        let pointCell = self.convert(point, to: cell)
        if cell.isCurl == false || cell.deleteButton.frame.contains(pointCell) {
            return nil
        }
        
        if cell.isCurl == true {
            cell.closeCurl()
            return self
        }
        
        return nil
    }
    
    static func closeOpenItem() {
        guard let cv = NoteCollectionViewInputOverlay.cacheCollectionView,
            let index = NoteCollectionViewInputOverlay.openedItemIndex,
            let cell = cv.cellForItem(at: index) as? NoteCollectionViewCell else { return }
        
        cell.closeCurl()
    }
}
