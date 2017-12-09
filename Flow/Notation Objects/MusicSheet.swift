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
    
    private let lineSpace:CGFloat = 30 // Spaces between lines in staff
    private let staffSpace:CGFloat = 280 // Spaces between staff
    private let lefRightPadding:CGFloat = 100 // Left and right padding of a staff
    private let startY:CGFloat = 200
    private let startYConnection:CGFloat = 80
    private let grandStaffSpace:CGFloat = 560 // change * 2 of staff space
    private var grandStaffIndex:CGFloat = 0
    private var staffIndex:CGFloat = -1
    
    private var grid = [[MusicNotation]]()
    
    private var endX: CGFloat {
        return bounds.width - lefRightPadding
    }
    
    override func draw(_ rect: CGRect) {
        /*drawStaff(startX: lefRightPadding, startY: startY + staffSpace * staffIndex, clefType: Clef.G)
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace, clefType: Clef.F)
        drawStaffConnection(startX: lefRightPadding, startY: 80)
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace * 2, clefType: Clef.G)
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace * 3, clefType: Clef.F)
        drawStaffConnection(startX: lefRightPadding, startY: 480)
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace * 4, clefType: Clef.G)
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace * 5, clefType: Clef.F)
        drawStaffConnection(startX: lefRightPadding, startY: 880)*/
        
        setupGrandStaff(startX: lefRightPadding, startY: startY)
        setupGrandStaff(startX: lefRightPadding, startY: startY)
        setupGrandStaff(startX: lefRightPadding, startY: startY)
    }
    
    //Setup a grand staff
    private func setupGrandStaff(startX:CGFloat, startY:CGFloat) {
        staffIndex += 1
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace * staffIndex, clefType: Clef.G)
        staffIndex += 1
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace * staffIndex, clefType: Clef.F)
        drawStaffConnection(startX: lefRightPadding, startY: startYConnection + grandStaffSpace * grandStaffIndex)
        
        grandStaffIndex += 1
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
        
        if clefType == .F {
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

    private func drawStaffConnection(startX:CGFloat, startY:CGFloat) {
        let bezierPath = UIBezierPath()
        UIColor.black.setStroke()
        bezierPath.lineWidth = 2
        
        bezierPath.move(to: CGPoint(x: startX, y: startY))
        bezierPath.addLine(to: CGPoint(x: startX, y: startY + 400)) // change if staff space changes
        bezierPath.stroke()
        
        bezierPath.move(to: CGPoint(x: endX, y: startY))
        bezierPath.addLine(to: CGPoint(x: endX, y: startY + 400)) // change if staff space changes
        bezierPath.stroke()
        
        bezierPath.move(to: CGPoint(x: (endX + startX) / 2, y: startY))
        bezierPath.addLine(to: CGPoint(x: (endX + startX) / 2, y: startY + 400)) // change if staff space changes
        bezierPath.stroke()
        
        let brace = UIImage(named:"brace-185")
        let braceView = UIImageView(frame: CGRect(x: lefRightPadding - 25, y: startY, width: 22.4, height: 400))
        
        braceView.image = brace
        self.addSubview(braceView)
    }
    
    public func addMusicNotation(note: MusicNotation) {
        print("ADD NOTE")
        
        let noteImageView = UIImageView(frame: CGRect(x: ((note.screenCoordinates)?.x)!, y: ((note.screenCoordinates)?.y)!, width: (note.image?.size.width)!, height: (note.image?.size.height)!))
        
        noteImageView.image = note.image
        
        self.addSubview(noteImageView)
    }
}