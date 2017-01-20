//
//  NoteTextView.swift
//  CopyBoard
//
//  Created by zhoubo on 2017/1/19.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

class NoteTextView: UITextView {

    var spliteLineColor: UIColor?
    
    override func draw(_ rect: CGRect) {
        //Get the current drawing context
        guard let lineColor = self.spliteLineColor,
            let context = UIGraphicsGetCurrentContext() else { return }
        let font = self.font ?? UIFont.systemFont(ofSize: 16)
        
        context.setStrokeColor(lineColor.cgColor)
        let baseOffset = self.textContainerInset.top + font.descender
        let screenScale = UIScreen.main.scale
        let boundsX = self.bounds.origin.x;
        let boundsWidth = self.bounds.size.width;
     
        let firstLine = Int(max(0, (self.contentOffset.y / font.lineHeight)))
        let lastLine = Int((self.contentOffset.y + self.bounds.height) / font.lineHeight)

        for line in firstLine..<lastLine {
            let linePointY = (baseOffset * 1 + ((font.lineHeight + 10) * CGFloat(line)))
            let roundedLinePointY = round(linePointY * screenScale) / screenScale
            context.move(to: CGPoint(x: boundsX, y: roundedLinePointY))
            context.addLine(to: CGPoint(x: boundsWidth, y: roundedLinePointY))
        }
        
        context.closePath()
        context.strokePath()
    }

}
