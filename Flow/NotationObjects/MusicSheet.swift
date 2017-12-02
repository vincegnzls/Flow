//
//  MusicSheet.swift
//  Flow
//
//  Created by Vince on 02/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

@IBDesignable
class MusicSheet: UIView {
    
    let lineSpace:CGFloat = 30 // Spaces between lines in staff
    let staffSpace:CGFloat = 200 // Spaces between stafff
    let lefRightPadding:CGFloat = 100 // Left and right padding of a staff
    let startY:CGFloat = 200
    var staffIndex:CGFloat = 0
    
    private var endX: CGFloat {
        return bounds.width - lefRightPadding
    }
    
    enum Clef {
        case G, F
    }
    
    override func draw(_ rect: CGRect) {
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace * staffIndex, clefType: Clef.G)
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace, clefType: Clef.F)
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace * 2, clefType: Clef.G)
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace * 3, clefType: Clef.F)
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace * 4, clefType: Clef.G)
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace * 5, clefType: Clef.F)
    }
    
    // Draws a staff
    private func drawStaff(startX:CGFloat, startY:CGFloat, clefType:Clef) {
        // Sets the line format
        let bezierPath = UIBezierPath()
        UIColor.black.setStroke()
        bezierPath.lineWidth = 2
        
        var curSpace:CGFloat = 0
        
        var clef = UIImage(named:"treble-clef")
        var clefView = UIImageView(frame: CGRect(x: 110, y: 45 + startY - 200, width: 67.2, height: 192))
        
        if clefType == Clef.F {
            clef = UIImage(named:"bass-clef")
            clefView = UIImageView(frame: CGRect(x: 110, y: 35 + startY - 200, width: 67.2, height: 192))
        }
        
        clefView.image = clef
        self.addSubview(clefView)
        
        for _ in 0..<5 {
            bezierPath.move(to: CGPoint(x: startX, y: startY - curSpace))
            bezierPath.addLine(to: CGPoint(x: endX, y: startY - curSpace))
            bezierPath.stroke()
            
            curSpace += lineSpace
        }
    }

}
