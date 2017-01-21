//
//  NoteCollectionViewLayout.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/21.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class NoteCollectionViewLayout: UICollectionViewLayout {

    var delegate: NoteCollectionViewLayoutDelegate
    var cellPadding: CGFloat = 6
    var numberOfColumns = 2
    
    private var cache = [NoteLayoutAttributes]()
    
    override class var layoutAttributesClass : AnyClass {
        return NoteLayoutAttributes.self
    }
    
    private var width: CGFloat = -1
    var itemWidth: CGFloat {
        get {
            if self.width == -1 {
                let columnWidth = self.contentWidth / CGFloat(self.numberOfColumns)
                self.width = columnWidth - cellPadding * 2
                return self.width
            } else {
                return self.width
            }
        }
    }
    
    private var contentHeight: CGFloat  = 0.0
    private var contentWidth: CGFloat {
        guard let cview = self.collectionView else {
            fatalError("self.collection view shold not be nil")
        }
        let insets = cview.contentInset
        return cview.bounds.width - (insets.left + insets.right)
    }
    
    
     init(delegate: NoteCollectionViewLayoutDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        guard let cview = self.collectionView else {
            fatalError("self.collection view shold not be nil")
        }
        
        if cache.isEmpty {
            let columnWidth = self.contentWidth / CGFloat(self.numberOfColumns)
            var xOffset = [CGFloat]()
            for column in 0..<self.numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth )
            }
            var column = 0
            var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
            
            // 3
            for item in 0 ..< cview.numberOfItems(inSection: 0) {
                
                let indexPath = IndexPath(item: item, section: 0)
                
                // 4
                let width = columnWidth - cellPadding * 2
                let noteHeight = delegate.collectionView(collectionView: cview, heightForRowAt: indexPath, withWidth: width)
//                let annotationHeight = delegate.collectionView(collectionView!,
//                                                               heightForAnnotationAtIndexPath: indexPath, withWidth: width)
                let height = cellPadding +  noteHeight /*+ annotationHeight */ + cellPadding
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                
                // 5
                let attributes = NoteLayoutAttributes(forCellWith: indexPath)
                attributes.noteHeight = noteHeight
                attributes.frame = insetFrame
                cache.append(attributes)
                
                // 6
                contentHeight = max(self.contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
                
                column = column >= (numberOfColumns - 1) ? 0 : (column + 1)
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes  in self.cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    override var collectionViewContentSize : CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

}

class NoteLayoutAttributes:UICollectionViewLayoutAttributes {
    
    // 1. Custom attribute
    var noteHeight: CGFloat = 0.0
    
    // 2. Override copyWithZone to conform to NSCopying protocol
    override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! NoteLayoutAttributes
        copy.noteHeight = noteHeight
        return copy
    }
    
    // 3. Override isEqual
    override func isEqual(_ object: Any?) -> Bool {
        if let attributtes = object as? NoteLayoutAttributes {
            if( attributtes.noteHeight == noteHeight  ) {
                return super.isEqual(object)
            }
        }
        return false
    }
}

protocol NoteCollectionViewLayoutDelegate {
    func collectionView(collectionView: UICollectionView,
                        heightForRowAt indexPath:IndexPath,
                        withWidth:CGFloat) -> CGFloat
}
