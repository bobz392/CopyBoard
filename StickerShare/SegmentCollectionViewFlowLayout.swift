//
//  File.swift
//  StickerShare
//
//  Created by zhoubo on 2020/5/5.
//  Copyright © 2020 zhoubo. All rights reserved.
//

import Foundation
//
//  SegmentLayout.swift
//  UILibrary
//
//  Created by zhoubo on 2020/5/1.
//

import UIKit

public class SegmentCollectionViewFlowLayout: UICollectionViewFlowLayout {
 
    // MARK: - Props
    /// If set to YES, enables the deselecting of cells by panning around on a touch down
    var panToDeselect: Bool = false
    /// If set to YES, a pan across a row and then down a column will auto-select all cells in each row as you scroll down (used to easily select a lot of cells rather than panning over every cell)
    var autoSelectRows: Bool = false
    /// If set to YES, enables auto-selecting all cells between a first and second selected cell
    var autoSelectCellsBetweenTouches: Bool = false
 
    private let collectionViewKeyPath = "collectionView"
    // MARK: Pan Gesture States
    private var selecting: Bool = false
    private var selectedRow: Bool = false
    private var selectRowCancelled: Bool = false
    private var pannedFromFirstColumn: Bool = false
    private var pannedFromLastColumn: Bool = false
    private var deselecting: Bool = false
    
    // MARK: Touch Gesture States
    private var initialSelectedIndexPath: IndexPath? = nil
    private var previousIndexPath: IndexPath? = nil
    // MARK: - Init
    class func layout(autoSelectRows: Bool,
                      panToDeselect: Bool,
                      autoSelectCellsBetweenTouches: Bool) {
        
    }
    
    public init(autoSelectRows: Bool,
                panToDeselect: Bool,
                autoSelectCellsBetweenTouches: Bool) {
        self.autoSelectRows = autoSelectRows
        self.panToDeselect = panToDeselect
        self.autoSelectCellsBetweenTouches = autoSelectCellsBetweenTouches
        super.init()
        
        addObserver(self, forKeyPath: collectionViewKeyPath,
                    options: .new, context: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {
        if let kp = keyPath,
            let _ = collectionView,
            kp == collectionViewKeyPath {
            setupCollectionView()
        }
    }
    
    deinit {
        removeObserver(self, forKeyPath: collectionViewKeyPath)
    }
    
    // MARK: - Gesture Logic
    
    private func setupCollectionView() {
        guard let cv = self.collectionView else { return }
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(gestureAction(gesture:)))
        let pan = UIPanGestureRecognizer(target: self,
                                         action: #selector(gestureAction(gesture:)))
        cv.addGestureRecognizer(tap)
        cv.addGestureRecognizer(pan)
        pan.delegate = self
    }
    
    @objc private func gestureAction(gesture: UIGestureRecognizer) {
        if let tap = gesture as? UITapGestureRecognizer {
            tapAction(tap: tap)
        } else if let pan = gesture as? UIPanGestureRecognizer {
            panAction(pan: pan)
        }
    }
    
    private func tapAction(tap: UITapGestureRecognizer) {
        guard let cv = self.collectionView else { return }
        // Get index path at tapped point
        let point = tap.location(in: cv)
        guard let indexPath = cv.indexPathForItem(at: point),
            let cell = cv.cellForItem(at: indexPath)
            else { return }
        
        // Handle tap
        if cell.isSelected {
            deselectCell(at: indexPath)
        } else {
            if autoSelectCellsBetweenTouches {
                if let initialSelectedIndexPath = initialSelectedIndexPath {
                    selectAllItem(from: initialSelectedIndexPath, to: indexPath)
                }
                initialSelectedIndexPath = nil
            } else {
                initialSelectedIndexPath = indexPath
            }
            selectCell(at: indexPath)
        }
    }
    
    private func panAction(pan: UIPanGestureRecognizer) {
        guard let cv = self.collectionView else { return }
        // Get velocity and point of pan
        let velocity = pan.velocity(in: cv)
        let point = pan.location(in: cv)
        
        if !cv.isDecelerating {
            // Handle pan
            if pan.state == .ended {
                // Reset pan states
                selecting = false
                selectedRow = false
                selectRowCancelled = false
                pannedFromLastColumn = false
                pannedFromFirstColumn = false
                deselecting = false
                previousIndexPath = nil
            } else {
                if abs(velocity.x) < abs(velocity.y) && !selecting {
                    // Register as scrolling the collection view
                    selecting = false
                } else {
                    // Register as selecting the cells, not scrolling the collection view
                    selecting = true
                    guard let indexPath = cv.indexPathForItem(at: point),
                        let cell = cv.cellForItem(at: indexPath)
                        else { return }
                    if cell.isSelected {
                        if panToDeselect {
                            if let pip = previousIndexPath,
                                pip == indexPath {
                                deselecting = true
                            }
                            if deselecting {
                                deselectCell(at: indexPath)
                            }
                        }
                    } else {
                        if !deselecting {
                            selectCell(at: indexPath)
                            if autoSelectRows {
                                handleAutoSelectingRows(at: indexPath)
                            }
                        }
                        
                    }
                    
                    
                }
            }
        }
    }
    
    //MARK: - Auto Select Rows Helpers
    private func handleAutoSelectingRows(at indexPath: IndexPath) {
        let nextIndexPath = IndexPath(item: indexPath.row + 1,
                                      section: indexPath.section)
        guard let cv = self.collectionView,
            let cell = cv.cellForItem(at: indexPath)
            else { return }
        
        let nextCell = cv.cellForItem(at: nextIndexPath)
        
        // Check to make sure we have not panned to another section
        if let pip = previousIndexPath,
            pip.section != indexPath.section {
            selectedRow = false
        } else {
            // Check if this is the initial pan from the first column
            if cell.frame.origin.x == minimumInteritemSpacing {
                // Is the first cell in the row
                pannedFromFirstColumn = true
            } else if let nextCell = nextCell,
                nextCell.frame.origin.x < cell.frame.origin.x {
                // Is the last cell in the row
                pannedFromLastColumn = true
            }
        }
        // Figure out if this cell is in the first or last column
        var didSelectAllItemsInRow = false
        if let nc = nextCell,
            nc.frame.origin.x < cell.frame.origin.x {
            if pannedFromFirstColumn {
                didSelectAllItemsInRow = didSelectAllItemInRow(at: indexPath)
            }
        } else if nextCell == nil {
            if pannedFromFirstColumn {
                didSelectAllItemsInRow = didSelectAllItemInRow(at: indexPath)
            }
        } else if cell.frame.origin.x == minimumInteritemSpacing {
            if pannedFromLastColumn {
                didSelectAllItemsInRow = didSelectAllItemInRow(at: indexPath)
            }
        }
        
        // Check if we should cancel the row select
        if let pip = previousIndexPath,
            !didSelectAllItemsInRow,
            labs(pip.row - indexPath.row) > 1 {
            selectRowCancelled = true
        }
    }
    
    // MARK: - Selection Helpers
    private func selectCell(at indexPath: IndexPath) {
        guard let cv = collectionView
            else { return }
        cv.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
        cv.delegate?.collectionView?(cv, didSelectItemAt: indexPath)
    }
    
    private func deselectCell(at indexPath: IndexPath) {
        guard let cv = collectionView
            else { return }
        cv.deselectItem(at: indexPath, animated: true)
        cv.delegate?.collectionView?(cv, didDeselectItemAt: indexPath)
    }

    private func selectAllItem(from initialIndexPath: IndexPath,
                               to finalIndexPath: IndexPath) {
        var initialIndexPath = initialIndexPath
        var finalIndexPath = finalIndexPath
        if initialIndexPath.section == finalIndexPath.section {
            // Check if initial and final index paths should be swapped
            if initialIndexPath.row == finalIndexPath.row {
                // Swap them
                let tempFinalIndex = IndexPath(item: finalIndexPath.row, section: finalIndexPath.section)
                finalIndexPath = tempFinalIndex
                initialIndexPath = tempFinalIndex
            }
            
            // Select cells
            var indexPath = initialIndexPath
            while indexPath.row < finalIndexPath.row {
                if let cv = collectionView,
                    let cell = cv.cellForItem(at: indexPath) {
                    if !cell.isSelected {
                        selectCell(at: indexPath)
                    }
                    indexPath = IndexPath(item: indexPath.row + 1,
                                          section: indexPath.section)
                }
            }
        }
        
    }

    private func didSelectAllItemInRow(at indexPath: IndexPath) -> Bool {
        if selectedRow {
            // A row has been selected, so select all cells in row
            if !selectRowCancelled {
                if pannedFromFirstColumn {
                    selectRowFromLastColumn(at: indexPath)
                } else {
                    selectFowFromFirstColumn(at: indexPath)
                }
                return true
            }
        } else {
            selectedRow = true
        }
        return false
    }
    
    private func selectFowFromFirstColumn(at indexPath: IndexPath) {
        guard let cv = collectionView else { return }
        var rowIndexPath = indexPath
        var cell: UICollectionViewCell
        
        // Used for figuring out when we are at the last cell on the column
        var nextCell: UICollectionViewCell?
        var nextIndexPath: IndexPath
        
        // Loop through the cells on this row (from left to right)
        repeat {
            rowIndexPath = IndexPath(item: rowIndexPath.row + 1,
                                     section: rowIndexPath.section)
            if let c = cv.cellForItem(at: rowIndexPath) {
                cell = c
                if !cell.isSelected {
                    selectCell(at: rowIndexPath)
                }
                nextIndexPath = IndexPath(row: rowIndexPath.row + 1,
                                          section: rowIndexPath.section)
                nextCell = cv.cellForItem(at: nextIndexPath)
            } else {
                break
            }
        } while nextCell != nil && nextCell!.frame.origin.x > cell.frame.origin.x
    }
    
    private func selectRowFromLastColumn(at indexPath: IndexPath) {
        guard let cv = collectionView else { return }
        var rowIndexPath = indexPath
        var cell: UICollectionViewCell
        
        // Loop through the cells on this row (from right to left)
        repeat {
            rowIndexPath = IndexPath(item: rowIndexPath.row - 1,
                                     section: rowIndexPath.section)
            if let c = cv.cellForItem(at: rowIndexPath) {
                cell = c
                if !cell.isSelected {
                    selectCell(at: rowIndexPath)
                }
            } else {
                break
            }
        } while cell.frame.origin.x != minimumInteritemSpacing
    }
}


extension SegmentCollectionViewFlowLayout: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !selecting
    }
    
}
