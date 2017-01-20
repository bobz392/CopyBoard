//
//  NoteTextView.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/19.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class NoteTextView: UITextView {

    static let NoteLineSpace: CGFloat = 15
    
    var noteFont = UIFont.systemFont(ofSize: 16)
    var spliteLineColor: UIColor?
    
    override func draw(_ rect: CGRect) {
        //Get the current drawing context
        guard let lineColor = self.spliteLineColor,
            let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(lineColor.cgColor)
        let baseOffset = self.textContainerInset.top + noteFont.descender
        let screenScale = UIScreen.main.scale
        let boundsX = self.bounds.origin.x;
        let boundsWidth = self.bounds.size.width;
     
        let firstLine = Int(max(1, (self.contentOffset.y / 35)))
        let lastLine = Int((self.contentOffset.y + self.bounds.height) / 35)

        for line in firstLine..<lastLine {
            let linePointY =
                (baseOffset + (35 * CGFloat(line)))
            let roundedLinePointY = round(linePointY * screenScale) / screenScale
            context.move(to: CGPoint(x: boundsX, y: roundedLinePointY))
            context.addLine(to: CGPoint(x: boundsWidth, y: roundedLinePointY))
        }
        
        context.closePath()
        context.strokePath()
    }

    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var originalRect = super.caretRect(for: position)
        originalRect.size.height = noteFont.lineHeight
        return originalRect
    }
    
    override func selectionRects(for range: UITextRange) -> [Any] {
        let rects = super.selectionRects(for: range)
        return rects.map { (r) -> Any in
            if let selectionRect = r as? UITextSelectionRect {
                print("UITextSelectionRect = \(selectionRect.rect)")
//                selectionRect.rect.size.height = noteFont.lineHeight
//                let s = UITextSelectionRect()
//                s.containsEnd = selectionRect.containsEnd
//                s.containsStart = selectionRect.containsStart
                return selectionRect
            }
            
            return r
        }
    }
}
