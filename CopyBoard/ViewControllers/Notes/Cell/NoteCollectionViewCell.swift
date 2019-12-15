//
//  NoteCollectionViewCell.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/21.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit
import SwiftDate

fileprivate let kCurlDeleteDuration: TimeInterval = 0.4
fileprivate let kCurlOpenDuration: TimeInterval = 0.3
fileprivate let kCurlCloseDuration: TimeInterval = 0.2
let kNoteViewAlphaAnimation: TimeInterval = 0.1

class NoteCollectionViewCell: UICollectionViewCell {
    
    static let nib = UINib(nibName: "NoteCollectionViewCell", bundle: nil)
    static let reuseId = "noteCollectionViewCell"
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var faveButton: FaveButton!
//    @IBOutlet weak var syncButton: UIButton!
    
    @IBOutlet weak var catelogueButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var noteDateLabel: UILabel!
    
    fileprivate var curlView: XBCurlView? = nil
    fileprivate var isCurl = false
    
    var note: Note? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        deleteButton.setImage(Icons.delete.iconImage(), for: .normal)
        deleteButton.tintColor = UIColor.white
        deleteButton.addTarget(self,
                               action: #selector(self.deleteAction),
                               for: .touchUpInside)
        
        faveButton.addTarget(self,
                             action: #selector(self.favourate),
                             for: .touchUpInside)
        noteLabel.textColor = AppColors.noteText
        noteDateLabel.textColor = AppColors.noteDate
        
        let rato: CGFloat = DeviceManager.shared.isPhone ? 0.4 : 0.8
        catelogueButton.titleLabel?.lineBreakMode = .byTruncatingTail
        catelogueButton.snp.makeConstraints { (maker) in
            maker.width.lessThanOrEqualTo(self.frame.width * rato)
        }
    }
    
    func configCell(use note: Note, query: String? = nil) {
        guard let pairColor =
            AppPairColors(rawValue: note.color)?.pairColor() else {
            fatalError("have no this type color")
        }
        
        self.note = note
        
        pairColor.dark.bgColor(to: headerView)
        pairColor.light.bgColor(to: cardView)
        
        faveButton.isSelected = note.favourite
        
        if let date = (AppSettings.shared.stickerDateUse == 0 ? note.createdAt : note.modificationDate) {
            self.noteDateLabel.text = date.toRelative()
        } else {
            self.noteDateLabel.text = nil
        }
        noteLabel.attributedText =
            note.content.searchHintString(isTruncated: isTruncated(),
                                          query: query)
        noteLabel.lineBreakMode = .byTruncatingMiddle
        self.configGesture()
        
        if let catelogue = note.category {
            catelogueButton.setTitle(catelogue, for: .normal)
        } else {
            catelogueButton
                .setTitle(Localized("defaultCatelogue"),
                          for: .normal)
        }
        
        catelogueButton.layer.cornerRadius = 12.0
        catelogueButton.layer.borderColor = UIColor.white.cgColor
        catelogueButton.layer.borderWidth = 1.0 / UIScreen.main.scale
    }
    
    private func isTruncated() -> Bool {
        
        if let string = note?.content {
            let size: CGSize = (string as NSString).boundingRect(
                with: CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: [NSAttributedString.Key.font: appFont(size: 16)],
                context: nil).size
            
            return (size.height > self.bounds.size.height)
        }
        
        return false
    }
    
    func configGesture() {
        if let grs = self.cardView.gestureRecognizers {
            for gr in grs {
                self.cardView.removeGestureRecognizer(gr)
            }
        }
        
        if AppSettings.shared.stickerGesture == 0 {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.gestureOpenAction))
            swipe.direction = .left
            self.cardView.addGestureRecognizer(swipe)
        } else {
            
            let long = UILongPressGestureRecognizer(target: self, action: #selector(self.gestureOpenAction))
            self.cardView.addGestureRecognizer(long)
        }
    }
    
    func deselectCell() {
        if let fave = self.note?.favourite {
            self.faveButton.isSelected = fave
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.madeShadow()
    }
    
    func madeShadow(highlight: Bool = false) {
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = highlight ? 6 : 3
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 0.15
        self.layer.shadowPath =
            UIBezierPath(rect: self.bounds).cgPath
        self.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    // MARK: - action
    @objc func gestureOpenAction() {
        Logger.log("sticker open action")
        guard !self.isCurl else { return }
        
        self.connectCollectionViewWithOverlay()
        guard let cv = NoteCollectionViewInputOverlay.cacheCollectionView,
            let index = cv.indexPath(for: self) else { return }
        self.curl(index: index)
    }
    
    func syncAction() {
        
    }
    
    @objc func deleteAction() {
        guard let cv = self.curlView else { return }
        let weakSelf =  self
        let alertVc =
            UIAlertController(title: Localized("revert"),
                              message: nil,
                              preferredStyle: .actionSheet)
        let sureAction =
            UIAlertAction(title: Localized("delete"),
                          style: .destructive)
            { (action) in
                weakSelf.closeCurl {
                    UIView.animate(withDuration: kCurlDeleteDuration, animations: {
                        cv.alpha = 0
                    }) { (finish) in
                        weakSelf.deleteRealmNote()
                    }
                }
        }
        
        let cancelAction =
            UIAlertAction(title: Localized("cancel"),
                          style: .cancel)
            { (action) in
                alertVc.dismiss(animated: true, completion: nil)
                weakSelf.closeCurl()
        }
        alertVc.addAction(cancelAction)
        alertVc.addAction(sureAction)
        
        UIApplication.shared
            .keyWindow?
            .rootViewController?
            .present(alertVc, animated: true, completion: nil)
    }
    
    fileprivate func deleteRealmNote() {
        guard  let n = self.note else {
            Logger.log("have no note to delete, maybe check it")
            return
        }
        
        DBManager.shared.deleteNote(note: n)
    }
    
    @objc func favourate() {
        guard  let n = self.note else {
            Logger.log("have no note to delete")
            return
        }
        
        DBManager.shared.updateNote(notify: false, note: n) { 
            n.favourite = !n.favourite
        }
        
    }
    
    func canEnter() -> Bool {
        if NoteCollectionViewInputOverlay.openedItemIndex == nil {
            return true
        } else {
            NoteCollectionViewInputOverlay.closeOpenItem()
            return false
        }
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
            
            let rato: CGFloat = DeviceManager.shared.isPhone ? 0.4 : 0.8
            let p = CGPoint(x: cardBounds.width * rato, y: cardBounds.height * rato)
            let angle = CGFloat(Double.pi / 2)
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
                    overlay.bgClear()
                    NoteCollectionViewInputOverlay.cacheCollectionView = cv
                    cv.addSubview(overlay)
                    NoteCollectionViewInputOverlay.connected = true
                    return
                }
                view = view?.superview
            }
        }
    }
    
    fileprivate func closeCurl(duration: Double = kCurlCloseDuration, completion: (() -> Void)? = nil) {
        self.curlView?.uncurlAnimated(withDuration: duration, completion: completion)
        
        self.curlView = nil
        self.isCurl = false
        NoteCollectionViewInputOverlay.openedItemIndex = nil
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
            NoteCollectionViewInputOverlay.cacheCollectionView?.allowsSelection = false
            cell.closeCurl()
            dispatchDelay(0.25, closure: { 
                NoteCollectionViewInputOverlay.cacheCollectionView?.allowsSelection = true
            })
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
