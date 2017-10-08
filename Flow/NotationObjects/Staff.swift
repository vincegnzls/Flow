//
//  Staff.swift
//  Flow
//
//  Created by Vince on 08/10/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

@IBDesignable
class Staff: UIView {
    
    var lineSpace : CGFloat = 0.0
    let lineSpaceAdder : CGFloat = 15.0
    var staffSpace: CGFloat = 100.0
    let staffSpaceAdder: CGFloat = 120.0
    var context: CGContext?
    
    init(width: CGFloat, height: CGFloat, context: CGContext?) {
        self.context = context
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var topMargin: CGFloat = 100.0
    private var botMargin: CGFloat = 100.0
    private var leftMargin: CGFloat {
        return bounds.minX + 100.0
    }
    private var rightMargin: CGFloat {
        return bounds.maxX - 100.0
    }
    
    func draw(yPosition:CGFloat) {
        context?.setLineWidth(1)
        context?.setStrokeColor(UIColor.black.cgColor)
        
        // draw 5 lines
        for _ in 1...5 {
            context?.move(to: CGPoint(x:leftMargin, y: (topMargin + lineSpace) + yPosition))
            context?.addLine(to: CGPoint(x: rightMargin, y: (topMargin + lineSpace) + yPosition))
            
            lineSpace += lineSpaceAdder
        }
        
        topMargin += staffSpace
        
        context?.strokePath()
    }
}

